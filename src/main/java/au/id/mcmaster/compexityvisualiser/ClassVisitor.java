package au.id.mcmaster.compexityvisualiser;

import au.id.mcmaster.compexityvisualiser.details.ClassDetails;

import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.ImportDeclaration;
import com.github.javaparser.ast.PackageDeclaration;
import com.github.javaparser.ast.TypeParameter;
import com.github.javaparser.ast.body.AnnotationDeclaration;
import com.github.javaparser.ast.body.AnnotationMemberDeclaration;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.ConstructorDeclaration;
import com.github.javaparser.ast.body.EmptyMemberDeclaration;
import com.github.javaparser.ast.body.EmptyTypeDeclaration;
import com.github.javaparser.ast.body.EnumConstantDeclaration;
import com.github.javaparser.ast.body.EnumDeclaration;
import com.github.javaparser.ast.body.FieldDeclaration;
import com.github.javaparser.ast.body.InitializerDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.body.MultiTypeParameter;
import com.github.javaparser.ast.body.Parameter;
import com.github.javaparser.ast.body.VariableDeclarator;
import com.github.javaparser.ast.body.VariableDeclaratorId;
import com.github.javaparser.ast.comments.BlockComment;
import com.github.javaparser.ast.comments.JavadocComment;
import com.github.javaparser.ast.comments.LineComment;
import com.github.javaparser.ast.expr.ArrayAccessExpr;
import com.github.javaparser.ast.expr.ArrayCreationExpr;
import com.github.javaparser.ast.expr.ArrayInitializerExpr;
import com.github.javaparser.ast.expr.AssignExpr;
import com.github.javaparser.ast.expr.BinaryExpr;
import com.github.javaparser.ast.expr.BooleanLiteralExpr;
import com.github.javaparser.ast.expr.CastExpr;
import com.github.javaparser.ast.expr.CharLiteralExpr;
import com.github.javaparser.ast.expr.ClassExpr;
import com.github.javaparser.ast.expr.ConditionalExpr;
import com.github.javaparser.ast.expr.DoubleLiteralExpr;
import com.github.javaparser.ast.expr.EnclosedExpr;
import com.github.javaparser.ast.expr.FieldAccessExpr;
import com.github.javaparser.ast.expr.InstanceOfExpr;
import com.github.javaparser.ast.expr.IntegerLiteralExpr;
import com.github.javaparser.ast.expr.IntegerLiteralMinValueExpr;
import com.github.javaparser.ast.expr.LambdaExpr;
import com.github.javaparser.ast.expr.LongLiteralExpr;
import com.github.javaparser.ast.expr.LongLiteralMinValueExpr;
import com.github.javaparser.ast.expr.MarkerAnnotationExpr;
import com.github.javaparser.ast.expr.MemberValuePair;
import com.github.javaparser.ast.expr.MethodCallExpr;
import com.github.javaparser.ast.expr.MethodReferenceExpr;
import com.github.javaparser.ast.expr.NameExpr;
import com.github.javaparser.ast.expr.NormalAnnotationExpr;
import com.github.javaparser.ast.expr.NullLiteralExpr;
import com.github.javaparser.ast.expr.ObjectCreationExpr;
import com.github.javaparser.ast.expr.QualifiedNameExpr;
import com.github.javaparser.ast.expr.SingleMemberAnnotationExpr;
import com.github.javaparser.ast.expr.StringLiteralExpr;
import com.github.javaparser.ast.expr.SuperExpr;
import com.github.javaparser.ast.expr.ThisExpr;
import com.github.javaparser.ast.expr.TypeExpr;
import com.github.javaparser.ast.expr.UnaryExpr;
import com.github.javaparser.ast.expr.VariableDeclarationExpr;
import com.github.javaparser.ast.stmt.AssertStmt;
import com.github.javaparser.ast.stmt.BlockStmt;
import com.github.javaparser.ast.stmt.BreakStmt;
import com.github.javaparser.ast.stmt.CatchClause;
import com.github.javaparser.ast.stmt.ContinueStmt;
import com.github.javaparser.ast.stmt.DoStmt;
import com.github.javaparser.ast.stmt.EmptyStmt;
import com.github.javaparser.ast.stmt.ExplicitConstructorInvocationStmt;
import com.github.javaparser.ast.stmt.ExpressionStmt;
import com.github.javaparser.ast.stmt.ForStmt;
import com.github.javaparser.ast.stmt.ForeachStmt;
import com.github.javaparser.ast.stmt.IfStmt;
import com.github.javaparser.ast.stmt.LabeledStmt;
import com.github.javaparser.ast.stmt.ReturnStmt;
import com.github.javaparser.ast.stmt.SwitchEntryStmt;
import com.github.javaparser.ast.stmt.SwitchStmt;
import com.github.javaparser.ast.stmt.SynchronizedStmt;
import com.github.javaparser.ast.stmt.ThrowStmt;
import com.github.javaparser.ast.stmt.TryStmt;
import com.github.javaparser.ast.stmt.TypeDeclarationStmt;
import com.github.javaparser.ast.stmt.WhileStmt;
import com.github.javaparser.ast.type.ClassOrInterfaceType;
import com.github.javaparser.ast.type.PrimitiveType;
import com.github.javaparser.ast.type.ReferenceType;
import com.github.javaparser.ast.type.UnknownType;
import com.github.javaparser.ast.type.VoidType;
import com.github.javaparser.ast.type.WildcardType;
import com.github.javaparser.ast.visitor.VoidVisitor;

public class ClassVisitor implements VoidVisitor<ClassDetails>
{
	private String packageName;
	
	public void visit(CompilationUnit node, ClassDetails classDetails)
	{
	}

	public void visit(PackageDeclaration node, ClassDetails classDetails)
	{
		packageName = node.getName().toString();
	}

	public void visit(ImportDeclaration node, ClassDetails classDetails)
	{
		String referenceName = node.getName().toString();
		classDetails.getOrCreateChildDetails(referenceName).incrementReferences();
	}

	public void visit(TypeParameter node, ClassDetails classDetails)
	{

	}

	public void visit(LineComment node, ClassDetails classDetails)
	{

	}

	public void visit(BlockComment node, ClassDetails classDetails)
	{

	}

	public void visit(ClassOrInterfaceDeclaration node, ClassDetails classDetails)
	{
		classDetails.setName(packageName + "." + node.getName());
	}

	public void visit(EnumDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(EmptyTypeDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(EnumConstantDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(AnnotationDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(AnnotationMemberDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(FieldDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(VariableDeclarator node, ClassDetails classDetails)
	{

	}

	public void visit(VariableDeclaratorId node, ClassDetails classDetails)
	{

	}

	public void visit(ConstructorDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(MethodDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(Parameter node, ClassDetails classDetails)
	{

	}

	public void visit(MultiTypeParameter node, ClassDetails classDetails)
	{

	}

	public void visit(EmptyMemberDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(InitializerDeclaration node, ClassDetails classDetails)
	{

	}

	public void visit(JavadocComment node, ClassDetails classDetails)
	{

	}

	public void visit(ClassOrInterfaceType node, ClassDetails classDetails)
	{
		String extendsString = node.getName();
		classDetails.getOrCreateChildDetails(extendsString).incrementReferences();
	}

	public void visit(PrimitiveType node, ClassDetails classDetails)
	{

	}

	public void visit(ReferenceType node, ClassDetails classDetails)
	{

	}

	public void visit(VoidType node, ClassDetails classDetails)
	{

	}

	public void visit(WildcardType node, ClassDetails classDetails)
	{

	}

	public void visit(UnknownType node, ClassDetails classDetails)
	{

	}

	public void visit(ArrayAccessExpr node, ClassDetails classDetails)
	{

	}

	public void visit(ArrayCreationExpr node, ClassDetails classDetails)
	{

	}

	public void visit(ArrayInitializerExpr node, ClassDetails classDetails)
	{

	}

	public void visit(AssignExpr node, ClassDetails classDetails)
	{

	}

	public void visit(BinaryExpr node, ClassDetails classDetails)
	{

	}

	public void visit(CastExpr node, ClassDetails classDetails)
	{

	}

	public void visit(ClassExpr node, ClassDetails classDetails)
	{

	}

	public void visit(ConditionalExpr node, ClassDetails classDetails)
	{

	}

	public void visit(EnclosedExpr node, ClassDetails classDetails)
	{

	}

	public void visit(FieldAccessExpr node, ClassDetails classDetails)
	{

	}

	public void visit(InstanceOfExpr node, ClassDetails classDetails)
	{

	}

	public void visit(StringLiteralExpr node, ClassDetails classDetails)
	{

	}

	public void visit(IntegerLiteralExpr node, ClassDetails classDetails)
	{

	}

	public void visit(LongLiteralExpr node, ClassDetails classDetails)
	{

	}

	public void visit(IntegerLiteralMinValueExpr node, ClassDetails classDetails)
	{

	}

	public void visit(LongLiteralMinValueExpr node, ClassDetails classDetails)
	{

	}

	public void visit(CharLiteralExpr node, ClassDetails classDetails)
	{

	}

	public void visit(DoubleLiteralExpr node, ClassDetails classDetails)
	{

	}

	public void visit(BooleanLiteralExpr node, ClassDetails classDetails)
	{

	}

	public void visit(NullLiteralExpr node, ClassDetails classDetails)
	{

	}

	public void visit(MethodCallExpr node, ClassDetails classDetails)
	{

	}

	public void visit(NameExpr node, ClassDetails classDetails)
	{

	}

	public void visit(ObjectCreationExpr node, ClassDetails classDetails)
	{

	}

	public void visit(QualifiedNameExpr node, ClassDetails classDetails)
	{

	}

	public void visit(ThisExpr node, ClassDetails classDetails)
	{

	}

	public void visit(SuperExpr node, ClassDetails classDetails)
	{

	}

	public void visit(UnaryExpr node, ClassDetails classDetails)
	{

	}

	public void visit(VariableDeclarationExpr node, ClassDetails classDetails)
	{

	}

	public void visit(MarkerAnnotationExpr node, ClassDetails classDetails)
	{

	}

	public void visit(SingleMemberAnnotationExpr node, ClassDetails classDetails)
	{

	}

	public void visit(NormalAnnotationExpr node, ClassDetails classDetails)
	{

	}

	public void visit(MemberValuePair node, ClassDetails classDetails)
	{

	}

	public void visit(ExplicitConstructorInvocationStmt node, ClassDetails classDetails)
	{

	}

	public void visit(TypeDeclarationStmt node, ClassDetails classDetails)
	{

	}

	public void visit(AssertStmt node, ClassDetails classDetails)
	{

	}

	public void visit(BlockStmt node, ClassDetails classDetails)
	{

	}

	public void visit(LabeledStmt node, ClassDetails classDetails)
	{

	}

	public void visit(EmptyStmt node, ClassDetails classDetails)
	{

	}

	public void visit(ExpressionStmt node, ClassDetails classDetails)
	{

	}

	public void visit(SwitchStmt node, ClassDetails classDetails)
	{

	}

	public void visit(SwitchEntryStmt node, ClassDetails classDetails)
	{

	}

	public void visit(BreakStmt node, ClassDetails classDetails)
	{

	}

	public void visit(ReturnStmt node, ClassDetails classDetails)
	{

	}

	public void visit(IfStmt node, ClassDetails classDetails)
	{

	}

	public void visit(WhileStmt node, ClassDetails classDetails)
	{

	}

	public void visit(ContinueStmt node, ClassDetails classDetails)
	{

	}

	public void visit(DoStmt node, ClassDetails classDetails)
	{

	}

	public void visit(ForeachStmt node, ClassDetails classDetails)
	{

	}

	public void visit(ForStmt node, ClassDetails classDetails)
	{

	}

	public void visit(ThrowStmt node, ClassDetails classDetails)
	{

	}

	public void visit(SynchronizedStmt node, ClassDetails classDetails)
	{

	}

	public void visit(TryStmt node, ClassDetails classDetails)
	{

	}

	public void visit(CatchClause node, ClassDetails classDetails)
	{

	}

	public void visit(LambdaExpr node, ClassDetails classDetails)
	{

	}

	public void visit(MethodReferenceExpr node, ClassDetails classDetails)
	{

	}

	public void visit(TypeExpr node, ClassDetails classDetails)
	{

	}
}
