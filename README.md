# solaris_elastic_vmstat_logging

Sparc is not a supported platform for elasticsearch. This is an example of using perl to json encode vmstat data and send to elasticsearch. 

Clean Solaris 11.3 installation

perl::JSON package will need to be added to system

perl -MCPAN -e shell

cpan[2]> install JSON

Read CreateIndex-Mapping.txt file to create elasticsearch index with proper mappings for vmstat output. 
