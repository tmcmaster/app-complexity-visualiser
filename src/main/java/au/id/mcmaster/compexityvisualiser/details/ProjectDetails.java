package au.id.mcmaster.compexityvisualiser.details;

public class ProjectDetails extends ComplexDetails<SourceDetails>
{
	protected ProjectDetails(String name)
    {
	    super(name);
    }

	@Override
    protected SourceDetails createChildDetails(String name)
    {
	    return new SourceDetails(name);
    }
}
