package au.id.mcmaster.compexityvisualiser;

import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;

import au.id.mcmaster.compexityvisualiser.details.ApplicationDetails;

public class ApplicationWalker
{
	public static ApplicationDetails getApplicationDetails(Path applicationPath)
	{
		return new ApplicationWalker().walk(applicationPath, new ApplicationVisitor(), new ApplicationDetails(applicationPath.toString()));
	}
	
	/**
	 * Walk file system recursively from given a given Path, looking for directories that contain a pom.xml file. 
	 */
    public ApplicationDetails walk(Path path, ApplicationVisitor applicationVisitor, ApplicationDetails applicationDetails)
    {
		try
		{
			Files.walkFileTree(path, new SimpleFileVisitor<Path>() {
				@Override
				public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
					throws IOException
				{
					if (file.resolve("pom.xml").toFile().exists())
					{
						// found a project directory
						applicationVisitor.visitProject(file, applicationDetails);
					}
					return FileVisitResult.CONTINUE;
				}
			});
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		return applicationDetails;
    }
}
