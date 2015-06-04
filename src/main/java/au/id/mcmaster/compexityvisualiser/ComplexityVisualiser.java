package au.id.mcmaster.compexityvisualiser;

import java.io.File;
import java.io.FileInputStream;
import java.nio.file.FileVisitOption;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import au.id.mcmaster.compexityvisualiser.details.ClassDetails;
import au.id.mcmaster.compexityvisualiser.details.InteractionDetails;
import au.id.mcmaster.compexityvisualiser.details.SourceDetails;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ast.CompilationUnit;

public class ComplexityVisualiser
{
	/************************************************************************************
	 * 
	 *  Main Section
	 * 
	 */
	
	public static void main(String[] args) throws Exception
	{
		if (args.length > 0)
		{
			build(args[0], (args.length > 1 ? args[1] : null));
		}
		else
		{
			System.err.println("Source directory path was not supplied. Optionally second argument is a package inclusion starts with filter.");
			System.exit(1);
		}
	}

	/************************************************************************************
	 * 
	 *  Data File Templates.
	 * 
	 */
	
	private static final String nodeTemplate = new StringBuilder()
		.append("    {").append("\n")
		.append("      'id':%d").append(",\n")
		.append("      'cluster':%d").append(",\n")
		.append("      'caption': '%s'").append("\n")
		.append("    }")
	.toString().replace('\'', '\"');
	
	private static final String edgeTemplate = new StringBuilder()
		.append("    {").append("\n")
		.append("      'source': %d").append(",\n")
		.append("      'target': %d").append(",\n")
		.append("      'caption': 'references'").append("\n")
		.append("    }")
	.toString().replace('\'', '\"');
	
	private static final String documentTemplate = new StringBuilder()
		.append("{").append("\n")
		.append("  'comment' :'%s'").append(",\n")
		.append("  'nodes': [").append("\n")
		.append("%s")
		.append("  ],").append("\n")
		.append("  'edges': [").append("\n")
		.append("%s")
		.append("  ]").append("\n")
		.append("}").append("\n")
	.toString().replace('\'', '\"');


	public static void build(String sourceDirectoryString, String filter)
		throws Exception
	{
		try
		{
			File sourceDirectory = new File(sourceDirectoryString);
		
			if (!sourceDirectory.exists())
			{
				System.err.println("Could not find the given source directory: " + sourceDirectoryString);
				System.exit(1);
			}
			else
			{
				if (!sourceDirectory.isDirectory())
				{
					System.err.println("given source path was not a directory: " + sourceDirectoryString);
					System.exit(2);
				}
			}
			
			SourceDetails sourceDetails = analyseProject(sourceDirectory);
			//printSourceDetails(sourceDetails);
			generateGraphData(sourceDetails, filter);
		}
		catch (Exception e)
		{
			throw new Exception("There was a problem while building the complexity graph.", e);
		}
	}

	private static class IdMapper extends HashMap<String, Integer>
	{
		private int counter = 0;
		
		public int getId(String name)
		{
			Integer id = get(name);
			if (id != null)
			{
				return id;
			}
			else
			{
				counter++;
				put(name, counter);
				return counter;
			}
		}
	}
	private static void generateGraphData(SourceDetails sourceDetails, String filter)
	{
		String comment = sourceDetails.getName();
		StringBuilder nodeData = new StringBuilder();
		StringBuilder edgeData = new StringBuilder();
		
		Set<String> nodeNames = new HashSet<String>();
		Map<String, ClassDetails> classDetailsMap = sourceDetails.getChildDetails();
		for (String className : classDetailsMap.keySet())
		{
			ClassDetails classDetails = classDetailsMap.get(className);
			nodeNames.add(classDetails.getName());
			Map<String, InteractionDetails> interactionDetailsMap = classDetails.getChildDetails();
			for (String interactionName : interactionDetailsMap.keySet())
			{
				if (filter == null || interactionName.startsWith(filter))
				{
					nodeNames.add(interactionName);
				}
			}
		}

		
		IdMapper nameIdMapper = new IdMapper();
		IdMapper clusterIdMapper = new IdMapper();
		
		int counter = 0;
		for (String nodeName : nodeNames)
		{
			counter++;
			int nameId = nameIdMapper.getId(nodeName);
			if (counter > 1)
			{
				nodeData.append(",\n");
			}
			String cluster = getCluster(nodeName);
			int clusterId = clusterIdMapper.getId(cluster);
			nodeData.append(String.format(nodeTemplate, nameId, clusterId, nodeName));
		}
		nodeData.append("\n");
		
		counter = 0;
		for (String className : classDetailsMap.keySet())
		{
			ClassDetails classDetails = classDetailsMap.get(className);
			
			Map<String, InteractionDetails> interactionDetailsMap = classDetails.getChildDetails();
			for (String interactionName : interactionDetailsMap.keySet())
			{
				if (filter == null || interactionName.startsWith(filter))
				{
					counter++;
					if (counter > 1)
					{
						edgeData.append(",\n");
					}
					int sourceId = nameIdMapper.get(classDetails.getName());
					int targetId = nameIdMapper.get(interactionName);
					edgeData.append(String.format(edgeTemplate, sourceId, targetId));
				}
			}
		}
		edgeData.append("\n");
		
		System.out.println(String.format(documentTemplate, comment, nodeData.toString(), edgeData.toString()));
	}

	private static String getCluster(String nodeName)
	{
		int index = nodeName.lastIndexOf('.');
		if (index < 0)
		{
			return "global";
		}
		else
		{
			return nodeName.substring(0, index);
		}
	}
	
	private static void printSourceDetails(SourceDetails sourceDetails)
	{
		System.out.println(String.format("SourceDetails(%s)", sourceDetails.getName()));
		
		Map<String, ClassDetails> classDetailsMap = sourceDetails.getChildDetails();
		for (String className : classDetailsMap.keySet())
		{
			ClassDetails classDetails = classDetailsMap.get(className);
			System.out.println(String.format("  ClassDetails(%s)", classDetails.getName()));
			
			Map<String, InteractionDetails> interactionDetailsMap = classDetails.getChildDetails();
			for (String interactionName : interactionDetailsMap.keySet())
			{
				InteractionDetails interactionDetails = interactionDetailsMap.get(interactionName);
				System.out.println(String.format("    InteractionDetails(%s): %d", interactionDetails.getName(), interactionDetails.getNumberOfReferences()));
			}
		}
	}
	
	private static SourceDetails analyseProject(File projectDirectory)
		throws Exception
	{
		final SourceDetails sourceDetails = new SourceDetails(projectDirectory.getAbsoluteFile().getName());
		
		Path projectPath = projectDirectory.toPath();
		Set<FileVisitOption> fileVisitOptions = new HashSet<FileVisitOption>();
		Files.walkFileTree(projectPath, fileVisitOptions, 100, new SimpleFileVisitor<Path>() {
			@Override
			public FileVisitResult visitFile(Path path, BasicFileAttributes attrs)
			{
				String fileName = path.toString();
				if (fileName.endsWith(".java"))
				{
					try
					{
						analyseFile(path, sourceDetails);
					}
					catch (Exception e)
					{
						e.printStackTrace();
					}
				}
				return FileVisitResult.CONTINUE;
			}
		});
		
		return sourceDetails;
	}
	
	public static void analyseFile(Path path, final SourceDetails sourceDetails)
		throws Exception
	{
		String fileName = path.toFile().getName();
		//System.out.println("About to process: " + fileName);

		ClassDetails classDetails = sourceDetails.getOrCreateChildDetails(fileName);
		CompilationUnit cu = JavaParser.parse(new FileInputStream(path.toFile()));
		
		new ClassWalker().walk(cu, new ClassVisitor(), classDetails);
	}
	
}