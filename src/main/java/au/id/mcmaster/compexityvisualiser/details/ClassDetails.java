package au.id.mcmaster.compexityvisualiser.details;

public class ClassDetails extends ComplexDetails<InteractionDetails>
{
	int reference = 0;
	
	public ClassDetails(String name)
    {
		super(name);
    }
	
	@Override
    protected InteractionDetails createChildDetails(String name)
    {
	    return new InteractionDetails(name) {};
    }
}
