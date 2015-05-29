package au.id.mcmaster.compexityvisualiser.details;

public class InteractionDetails extends Details
{
	private int reference = 0;
	
	public InteractionDetails(String name)
    {
	    super(name);
    }

	public void incrementReferences()
	{
		this.reference++;
	}
	
	public int getNumberOfReferences()
	{
		return reference;
	}
}
