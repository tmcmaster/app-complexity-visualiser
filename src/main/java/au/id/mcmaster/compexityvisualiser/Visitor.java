package au.id.mcmaster.compexityvisualiser;

public interface Visitor<N extends Object, S extends Object>
{
	public void visit(N node, S state);
}
