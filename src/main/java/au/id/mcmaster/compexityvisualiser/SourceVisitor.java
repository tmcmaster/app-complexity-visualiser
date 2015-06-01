package au.id.mcmaster.compexityvisualiser;

import java.io.FileInputStream;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.regex.Pattern;

import au.id.mcmaster.compexityvisualiser.details.ClassDetails;
import au.id.mcmaster.compexityvisualiser.details.SourceDetails;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ast.CompilationUnit;

public class SourceVisitor extends SimpleFileVisitor<Path>
{
	private Path baseDir;
	private Pattern filePattern;
	private ClassWalker classWalker = new ClassWalker();
	private SourceDetails SourceDetails;

	public SourceVisitor(Path baseDir)
	{
		this.baseDir = baseDir;
		this.filePattern = Pattern.compile(".*\\.java");
		this.SourceDetails = new SourceDetails(baseDir.toString());
	}
	
	public SourceDetails getReleationshipDetails()
	{
		return this.SourceDetails;
	}
	
	
	@Override
	public FileVisitResult visitFile(Path path, BasicFileAttributes attrs)
	{
		System.out.println(String.format("SourceVisitor.visit(%s)",path));
		try
		{
			if (!attrs.isDirectory())
			{
				if (filePattern.matcher(path.toString()).matches())
				{
					System.out.println("About to process: " + path.toString().substring(baseDir.toString().length()+1));
					CompilationUnit cu = JavaParser.parse(new FileInputStream(path.toFile()));
					ClassDetails SourceDetails = this.SourceDetails.getChildDetails(path.toString());
					classWalker.walk(cu, new ClassVisitor(), SourceDetails);
				}
				else
				{
					System.out.println("Ignoring: " + path.getFileName());			
				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		return FileVisitResult.CONTINUE;
	}
}