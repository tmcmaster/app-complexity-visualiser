package au.id.mcmaster.compexityvisualiser.details;

public class ApplicationDetails extends ComplexDetails<ProjectDetails>
{
	public ApplicationDetails(String name)
    {
	    super(name);
    }

	@Override
    protected ProjectDetails createChildDetails(String name)
    {
	    return new ProjectDetails(name);
    }
}
