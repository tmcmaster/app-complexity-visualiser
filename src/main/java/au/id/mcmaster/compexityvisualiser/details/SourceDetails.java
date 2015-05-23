package au.id.mcmaster.compexityvisualiser.details;

public class SourceDetails extends ComplexDetails<ClassDetails>
{
	public SourceDetails(String name)
    {
		super(name);
    }

	@Override
    protected ClassDetails createChildDetails(String name)
    {
	    return new ClassDetails(name);
    }
}
