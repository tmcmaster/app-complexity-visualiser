package au.id.mcmaster.compexityvisualiser;

import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.visitor.VoidVisitor;

public class ClassWalker
{
	public <A extends Object> void walk(Node node, VoidVisitor<A> visitor, A state)
	{
		//String nodeString = node.toString();
		//System.out.println(nodeString);
		node.accept(visitor, state);
		for (Node child : node.getChildrenNodes())
		{
			walk(child.getClass().cast(child), visitor, state);
		}
	}
}
