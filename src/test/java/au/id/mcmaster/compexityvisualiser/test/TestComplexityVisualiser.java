package au.id.mcmaster.compexityvisualiser.test;

import junit.framework.Assert;

import org.junit.Test;

import au.id.mcmaster.compexityvisualiser.ComplexityVisualiser;

public class TestComplexityVisualiser
{
	@Test
	public void test()
	{
		try
		{
			//String sourceDirectoryString = "C:/Users/Tim/Workspace/Clone/javaparser/javaparser-core/src/main/java";
			//String sourceDirectoryString = "C:/Users/Tim/Workspace/Clone/betterFORM/core/src/main/java";
			String sourceDirectoryString = "C:/Users/Tim/Workspace/Clone/Jersey";
			ComplexityVisualiser.build(sourceDirectoryString, "com.github.javaparser");
		}
		catch (Exception e)
		{
			e.printStackTrace();
			Assert.fail("Should not have thrown an exception: " + e.getMessage());
		}
	}

}
