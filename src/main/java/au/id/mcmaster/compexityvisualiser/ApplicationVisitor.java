package au.id.mcmaster.compexityvisualiser;

import java.nio.file.Path;

import au.id.mcmaster.compexityvisualiser.details.ApplicationDetails;

public class ApplicationVisitor
{
    public void visitProject(Path projectPath, ApplicationDetails applicationDetails)
    {
		System.out.println(String.format("ApplicationVisitor: ProjectPath(%s)", projectPath));
		new ProjectWalker().walk(projectPath, new ProjectVisitor(projectPath), applicationDetails.getOrCreateChildeDetails(projectPath));
    }
    
}
