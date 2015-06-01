package au.id.mcmaster.compexityvisualiser;

import java.nio.file.FileVisitOption;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Set;

import au.id.mcmaster.compexityvisualiser.details.ProjectDetails;

/**
 * Processes a given project source directory.
 * 
 * @author Tim McMaster
 */
public class ProjectVisitor
{
	private Path baseDir;
	private SourceWalker sourceWalker = new SourceWalker();
	
	public ProjectVisitor(Path baseDir)
	{
		this.baseDir = baseDir;
	}
	
	public void visitPath(Path sourcePath, ProjectDetails projectDetails)
	{
		try
		{
			System.out.println(String.format("ProjectVistor.visit(%s)",sourcePath));
			
			SourceVisitor sourceVisitor = new SourceVisitor(sourcePath);
			sourceWalker.walk(sourcePath, sourceVisitor);
			Set<FileVisitOption> fileVisitOptions = new HashSet<FileVisitOption>();
			Files.walkFileTree(sourcePath, fileVisitOptions, 100, sourceVisitor);
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}