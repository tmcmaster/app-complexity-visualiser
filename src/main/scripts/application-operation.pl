#!/usr/bin/perl

# InheritanceResolvementPlanBuilder.java:33 au.com.cgu.cudos.offeringmanager.service.offering.inheritance.resolver.dependency.plan.InheritanceResolvementPlanBuilder.appendChildDependencyFormula(WorkflowMapDependency:List),62,0,47
# AbstractSchemaElementImpl.java:170,265,265,69
# java.lang.Thread.run(),702324,654547,2
# au.com.cgu.drex.web.interaction.InteractionController.onPostRequest(AbstractItemGroup:BindingResult:HttpServletRequest),10967,0,21
# NativeConstructorAccessorImpl.java (native) org.ow2.easywsdl.wsdl.org.w3.ns.wsdl.MessageRefType$JaxbAccessorF_element.<init>(),31,31,49
# <generated> org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept(Object:Method:Object[]:MethodProxy),199,15,31

use strict;

my $fh;

open($fh, "<", "scratch/profiling-new-policy.csv");

my $file;
my $line;
my $package;
my $class;
my $method;
my $params;
my $totalTime;
my $methodTime;
my $depth;

my $operation = "new-policy";
my $prevPackage = undef;
my $prevClass = undef;

print "Operation,FromPackage,FromClass,MethodCall,ToPackage,ToClass,Sequence,CompletionTime,Duration\n";

my $sequence = 0;
while (<$fh>)
{
	chomp($_);

	#print "\n----[$_]\n";
	unless ($_ =~ m/Call Tree/ || $_ =~ m/All threads/)
	{
		$sequence++;

		if ($_ =~ m/(.*):([0-9]*) (.*)\.(.*?)\.(.*?)\((.*)\),([0-9]*),([0-9]*),([0-9]*)/)
		{
			($file, $line, $package, $class, $method, $params, $totalTime, $methodTime, $depth) = ($1, $2, $3, $4, $5, $6, $7, $8, $9);
			#print "\n# A----[$_]\n[ $file ],[ $line ],[ $package ],[ $class ],[ $method ],[ $params ],[ $totalTime ],[ $methodTime ],[ $depth ]\n";
		}
		elsif ($_ =~ m/(.*):([0-9]*),([0-9]*),([0-9]*),([0-9]*)/)
		{
			($file, $line, $package, $class, $method, $params, $totalTime, $methodTime, $depth) = ($1, $2, $package, $class, $method, $params, $3, $4, $5);
			#print "\n# B----[$_]\n[ $file ],[ $line ],[ $package ],[ $class ],[ $method ],[ $params ],[ $totalTime ],[ $methodTime ],[ $depth ]\n";
		} 
		elsif ($_ =~ m/<generated> (.*)\.(.*?)\.(.*?)\((.*)\),([0-9]*),([0-9]*),([0-9]*)/)
		{
			($file, $line, $package, $class, $method, $params, $totalTime, $methodTime, $depth) = (undef, undef, $1, $2, $3, $4, $5, $6, $7);
			#print "\n# D----[$_]\n[ $file ],[ $line ],[ $package ],[ $class ],[ $method ],[ $params ],[ $totalTime ],[ $methodTime ],[ $depth ]\n";
		}
		elsif ($_ =~ m/(.*) \(native\) (.*)\.(.*?)\.(.*?)\((.*)\),([0-9]*),([0-9]*),([0-9]*)/)
		{
			($file, $line, $package, $class, $method, $params, $totalTime, $methodTime, $depth) = ($1, undef, $2, $3, $4, $5, $6, $7, $8);
			#print "\n# E----[$_]\n[ $file ],[ $line ],[ $package ],[ $class ],[ $method ],[ $params ],[ $totalTime ],[ $methodTime ],[ $depth ]\n";
		}
		elsif ($_ =~ m/(.*)\.(.*?)\.(.*?)\((.*)\),([0-9]*),([0-9]*),([0-9]*)/)
		{
			($file, $line, $package, $class, $method, $params, $totalTime, $methodTime, $depth) = (undef, undef, $1, $2, $3, $4, $5, $6, $7);
			#print "\n# C----[$_]\n[ $file ],[ $line ],[ $package ],[ $class ],[ $method ],[ $params ],[ $totalTime ],[ $methodTime ],[ $depth ]\n";
		}

		printf("%s,%s,%s,%s(%s),%s,%s,%d,%d,%d\n", $operation, $prevPackage, $prevClass, $method, $params, $package, $class, $sequence, $totalTime, $methodTime);
		
		$prevPackage = $package;
		$prevClass = $class;

		#print "[ $file ],[ $line ],[ $package ],[ $class ],[ $method ],[ $params ],[ $totalTime ],[ $methodTime ],[ $depth ]\n";
	}
}
close($fh);