package au.id.mcmaster.compexityvisualiser;

public interface Walker<N extends Object, S extends Object>
{
	public void walk(N node, Visitor<N, S> visitor, S state);
}
