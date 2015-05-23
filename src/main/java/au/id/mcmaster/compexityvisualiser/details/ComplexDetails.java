package au.id.mcmaster.compexityvisualiser.details;

import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

public abstract class ComplexDetails<D extends Details> extends Details
{
	private Map<String, D> childDetailsMap = new HashMap<String, D>();
	
	protected ComplexDetails(String name)
	{
		super(name);
	}
	
	public Map<String, D> getChildDetails()
	{
		return childDetailsMap;
	}
	
	public D getChildDetails(String child)
	{
		return childDetailsMap.get(child);
	}
	
	public D getOrCreateChildeDetails(Path path)
	{
		return getChildDetails(path.toString());
	}
	
	public D getOrCreateChildDetails(String child)
	{
		D childDetails = getChildDetails(child);
		if (childDetails == null)
		{
			childDetails = createChildDetails(child);
			childDetailsMap.put(child, childDetails);
		}
		return childDetails;
	}
	
	protected abstract D createChildDetails(String name);
}
