#!/usr/bin/perl

use strict;

my $dir;
if ($#ARGV eq -1)
{
	$dir = `pwd`;
}
else
{
	$dir = $ARGV[0];
}

if ($dir =~ m/\/$/)
{
	chop($dir);
}

unless (-d $dir)
{
	die "Given directory was invalid: $dir";
}

my @pomFiles = (`find $dir -name pom.xml |egrep -v '\/build\/|\/target\/|\/.metadata\/'`);

printf("Project,name,%s,edge,CONTAINS\n",$dir);
my $line;
for $line (@pomFiles)
{
	chomp($line);
	$line =~ qr/$dir\/(.*)\/pom.xml/;
	my $projectPath = $1;
	if (-f "$dir/$projectPath/target/dependency-tree.txt")
	{
		my $path = '';
		my $module = $projectPath;
		if ($projectPath =~ m/\//)
		{
			($path,$module) = $projectPath =~ m/(.*)\/(.*)/;
		}
		printf("Module,name,%s,path,%s\n",$module,$path);
	}
}

# /cygdrive/d/work/projects-tim-hold/capella/capella-dev-kit-maven-plugin/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella/dev-kit/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella/libs/components/interaction/navigation/primary-secondary/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella/libs/freemarker/template-processor/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella/src/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella-useful/capella-dev-kit-maven-plugin/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella-useful/dev-kit/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella-useful/libs/components/interaction/navigation/primary-secondary/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella-useful/libs/freemarker/template-processor/pom.xml
# /cygdrive/d/work/projects-tim-hold/capella-useful/src/pom.xml
# /cygdrive/d/work/projects-tim-hold/cgu-wimp/parentpom/pom.xml
# /cygdrive/d/work/projects-tim-hold/cgu-wimp/pom.xml
# /cygdrive/d/work/projects-tim-hold/cgu-wimp/wimp/pom.xml
# /cygdrive/d/work/projects-tim-hold/cgu-wimp/wimp-manager/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/chdef-to-db-persister/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-bne/bne-daemon/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-bne/bne-manager/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-config-tool/cudos-config-tool-ui/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-config-tool/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-cx-conf-data-mgr/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-drex-extensions/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-drex-xml-pd-builder/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-insurance-tx-data-mgr/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/core/cx/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/core/exceptions/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/database/crud-manager/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/document/converter/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/document/generator/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/logging/aop-logging/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/logging/remote-logger/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/persistence/jpa-generic-dao/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/rae/rae-interface-extractor/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/referenceData/generic-reference-data/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/referenceData/reference-data/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/sunriseInterface/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/test/excel/tool/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/webService/wsRequestBuilder/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/webService/wsRequestSubmitter/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/xml/xml-serialisation/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/xml/xml-stax/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-libraries/xml/xmlToDom/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-offering-manager/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-pd-builder/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-pd-builder-drex-delegates/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-ui/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/cudos-ui/sample/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/drex/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/drex-isl/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/drex-refImpl/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos/drex_dev_artefacts/maven/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos-misc-spikes/enterprise/bpm/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos-misc-spikes/enterprise/dms/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos-misc-spikes/enterprise/idam/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos-misc-spikes/tools/DataImportExport/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos-misc-spikes/tools/OfferingViewScriptGenerator/pom.xml
# /cygdrive/d/work/projects-tim-hold/cudos-misc-spikes/tools/table-data-exporter/pom.xml


