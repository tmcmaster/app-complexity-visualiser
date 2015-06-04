package au.id.mcmaster.compexityvisualiser;

import java.nio.file.FileVisitOption;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Set;

public class SourceWalker
{
	public void walk(Path path, SourceVisitor visitor)
	{
		try
		{
			System.out.println(String.format("SourceWalker.walk(%s)",path));
			Set<FileVisitOption> fileVisitOptions = new HashSet<FileVisitOption>();
			Files.walkFileTree(path, fileVisitOptions, 100, visitor);
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}
