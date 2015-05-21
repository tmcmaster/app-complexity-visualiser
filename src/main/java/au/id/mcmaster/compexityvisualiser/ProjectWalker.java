package au.id.mcmaster.compexityvisualiser;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import au.id.mcmaster.compexityvisualiser.details.ProjectDetails;

public class ProjectWalker
{
	private List<String> sourcePaths = new ArrayList<String>();
	
	public ProjectWalker()
	{
		sourcePaths.add("src/main/java");
	}
	
    public void walk(Path applicationPath, ProjectVisitor projectVisitor, ProjectDetails projectDetails)
    {
		List<String> sourcePaths = getSourcePaths(applicationPath);
		
		for (String sourcePathString : sourcePaths)
		{
			Path sourcePath = applicationPath.resolve(sourcePathString);
			projectVisitor.visitPath(sourcePath, projectDetails);
		}

    }
	
	private List<String> getSourcePaths(Path applicationPath)
    {
	    List<String> sourcePaths = new ArrayList<String>();
	    
	    sourcePaths.add("src/main/java");
	    
	    return sourcePaths;
    }

}
