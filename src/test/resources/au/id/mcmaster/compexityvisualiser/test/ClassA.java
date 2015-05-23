package au.id.mcmaster.compexityvisualiser.test;

public class ClassA extends AbstractClass
{
	private ClassB classB = new ClassB();
	
	private int fieldB = -1;

	public ClassA(String fieldA, int fieldB)
	{
		super(fieldA);
		this.setFieldB(fieldB);
	}

	public int getFieldB() {
		return fieldB;
	}

	public void setFieldB(int fieldB) {
		this.fieldB = fieldB;
	}
	
	public ClassA clone(final int fieldB)
	{
		return new ClassA(this.getFieldA(), fieldB);
	}
}
