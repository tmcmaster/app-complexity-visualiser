package au.id.mcmaster.compexityvisualiser.test;

import java.io.FileInputStream;
import java.util.HashMap;
import java.util.Map;

import junit.framework.Assert;

import org.junit.Test;

import au.id.mcmaster.compexityvisualiser.ClassVisitor;
import au.id.mcmaster.compexityvisualiser.ClassWalker;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.PackageDeclaration;
import com.github.javaparser.ast.visitor.DumpVisitor;

public class TestClassWalker
{
	@Test
	public void smokeTest()
	{
		new ClassWalker();
	}

	@Test
	public void testWalk()
	{
		DumpVisitor visitor = new DumpVisitor();
		try (
			FileInputStream in = new FileInputStream("src/test/resources/au/id/mcmaster/compexityvisualiser/test/ClassA.java")
		) {
			CompilationUnit cu = JavaParser.parse(in);
			Map<String,Number> state = new HashMap<String, Number>();
			new ClassWalker().walk(cu, visitor, state);
		}
		catch (Exception e)
		{
			e.printStackTrace();
			Assert.fail("Should not have thrown an exception: " + e.getMessage());
		}
		System.out.println(visitor.getSource());
	}
}
