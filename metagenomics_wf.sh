#rule init_structure:

Scripts/init_sample.sh metagenomics {sample}  /export/lv7/rawdata/{sample}_1.fastq.gz /export/lv7/rawdata/{sample}_2.fastq.gz

#rule skip_split_assembly:

echo "contigs.fasta has not been splitted" > metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/split_flag.txt

#rule create_taxo_out:

touch metagenomics/runs/biodegradation/{sample}_data/no_tax.txt

#rule fast_qc:

fastqc metagenomics/samples/MBL1/rawdata/fw.fastq.gz metagenomics/samples/MBL1/rawdata/rv.fastq.gz --extract -t 4 -o metagenomics/samples/MBL1/qc/

#rule validateQC:

Scripts/validateQC.py

#rule trimmomatic:

trimmomatic PE -threads 35 metagenomics/samples/MBL1/rawdata/fw.fastq.gz metagenomics/samples/MBL1/rawdata/rv.fastq.gz metagenomics/runs/biodegradation/{sample}_data/trimmed/read1_paired.fq metagenomics/runs/biodegradation/{sample}_data/trimmed/read1_singles.fq metagenomics/runs/biodegradation/{sample}_data/trimmed/read2_paired.fq metagenomics/runs/biodegradation/{sample}_data/trimmed/read2_singles.fq ILLUMINACLIP:/export/lv5/software/anaconda/2022.05/envs/metacascabel_c_env/share/trimmomatic-0.39-2/adapters/TruSeq3-PE-2.fa:1:30:10:5:TRUE SLIDINGWINDOW:5:22 MAXINFO:40:0.6 MINLEN:100 > metagenomics/runs/biodegradation/{sample}_data/trimmed/trimmomatic.log 2>&1

#rule qc_trimmed_reads:

fastqc metagenomics/runs/biodegradation/{sample}_data/trimmed/read1_paired.fq metagenomics/runs/biodegradation/{sample}_data/trimmed/read2_paired.fq --extract -t 20 -o metagenomics/runs/biodegradation/{sample}_data/trimmed/qc/

#rule backup_trimmed_reads:

if [ ! -d "/export/lv9/projects/MBL1/trimmed_reads" ]; then     mkdir /export/lv9/projects/MBL1/trimmed_reads ; echo "Trimmed reads folder created..." ;fi;gzip -c metagenomics/runs/biodegradation/{sample}_data/trimmed/read1_paired.fq > /export/lv9/projects/MBL1/trimmed_reads/{sample}_read1_paired.fq.gz; gzip -c metagenomics/runs/biodegradation/{sample}_data/trimmed/read1_singles.fq > /export/lv9/projects/MBL1/trimmed_reads/{sample}_read1_singles.fq.gz; gzip -c metagenomics/runs/biodegradation/{sample}_data/trimmed/read2_paired.fq > /export/lv9/projects/MBL1/trimmed_reads/{sample}_read2_paired.fq.gz; gzip -c metagenomics/runs/biodegradation/{sample}_data/trimmed/read2_singles.fq > /export/lv9/projects/MBL1/trimmed_reads/{sample}_read2_singles.fq.gz; echo "Files backedup at: "  /export/lv9/projects/MBL1/trimmed_reads > metagenomics/runs/biodegradation/{sample}_data/trimmed/backup.log

#rule validateQCTrimm:

Scripts/validateQC.py

#rule megahit:

megahit -1 metagenomics/runs/biodegradation/{sample}_data/trimmed/read1_paired.fq -2 metagenomics/runs/biodegradation/{sample}_data/trimmed/read2_paired.fq -f --k-min 21 --k-max 141 --k-step 14  -m 0.7 -t 100 -o metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT

#rule std_assembly_megahit:

mv metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/final.contigs.fa metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta && ln -sr metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/scaffolds.fasta

#rule quast_scaffolds:

quast.py -t 50 -o metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/quast/scaffolds/ -s   metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/scaffolds.fasta

#rule anvio_reformat:

anvi-script-reformat-fasta -l 2500 --simplify-names --prefix MBL1 -o metagenomics/runs/biodegradation/{sample}_data/anvio/{sample}_2500nt.fa -r metagenomics/runs/biodegradation/{sample}_data/anvio/{sample}_2500_names_map.txt metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta

#rule backup_assembly:

if [ ! -d "/export/lv9/projects/MBL1/assembly" ]; then     mkdir /export/lv9/projects/MBL1/assembly ; echo "Asssembly folder created..." ;fi;gzip -c metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta > /export/lv9/projects/MBL1/assembly/{sample}_contigs.fasta.gz; echo "Assembly files backedup at: "  /export/lv9/projects/MBL1/assembly > metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/backup.log

#rule quast_contigs:

quast.py -t 50 -o metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/quast/contigs/  metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta

#rule anvio_create_db:

anvi-gen-contigs-database -f metagenomics/runs/biodegradation/{sample}_data/anvio/{sample}_2500nt.fa -o metagenomics/runs/biodegradation/{sample}_data/anvio/{sample}_2500_nt_CONTIGS.db -n MBL1 -T 10

#rule validate_assembly:

Scripts/validateQuast.py

#rule anvio_RNA:

anvi-run-hmms -c metagenomics/runs/biodegradation/{sample}_data/anvio/{sample}_2500_nt_CONTIGS.db -H /export/data01/databases/anvio_dbs/HMM_RNA_a -T 10 --just-do-it > metagenomics/runs/biodegradation/{sample}_data/anvio/{sample}_RNA.log

#rule bwa_index:

bwa index -p metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_assembly metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta

#rule anvio_get_RNA_seqs:

anvi-get-sequences-for-hmm-hits -c metagenomics/runs/biodegradation/{sample}_data/anvio/{sample}_2500_nt_CONTIGS.db --get-aa-sequences -o metagenomics/runs/biodegradation/{sample}_data/anvio/MBL1.RNA.hits.faa

#rule bwa_mem:

nice -0 bwa mem -t 35 metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_assembly metagenomics/runs/biodegradation/{sample}_data/trimmed/read1_paired.fq metagenomics/runs/biodegradation/{sample}_data/trimmed/read2_paired.fq | samtools view --threads 35 -b - | samtools sort - -o metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_mapped_against_cross-assembly_sorted.bam --threads 35

#rule sam_flags:

samtools flagstat --threads 35 metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_mapped_against_cross-assembly_sorted.bam > metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_mapped_against_cross-assembly_sorted.flagstat

#rule summarize_bam:

jgi_summarize_bam_contig_depths --outputDepth metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt  metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_mapped_against_cross-assembly_sorted.bam

#rule backup_coverage:

if [ ! -d "/export/lv9/projects/MBL1/coverage" ]; then     mkdir /export/lv9/projects/MBL1/coverage ; echo "Bin table folder created..." ;fi;cp metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_mapped_against_cross-assembly_sorted.bam  /export/lv9/projects/MBL1/coverage/MBL1.assembly.sorted.bam; cp metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_mapped_against_cross-assembly_sorted.flagstat  /export/lv9/projects/MBL1/coverage/MBL1.assembly.flagstats.txt; cp metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt  /export/lv9/projects/MBL1/coverage/MBL1.depth.txt; echo "Assembly files backedup at: "  /export/lv9/projects/MBL1/coverage/MBL1.assembly.sorted.bam > metagenomics/runs/biodegradation/{sample}_data/bwa-mem/backup.log

#rule avg_coverage:

cut -f1,3 metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt > metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth_avg.txt

#rule log_transform_coverage:

cat metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt | awk 'NR>1 && $3>1{ if($3 <= 1) a = 0; else  a = log($3)/log(10); printf("%s\t%0.4f\n",$1,a)}' > metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth_avg_log.txt

#rule metabat:

metabat2 -o metagenomics/runs/biodegradation/{sample}_data/binning/metabat2/CONTIGS_MEGAHIT/bin -i metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta -t 35 -m 2500 -a metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt --minS 30 --maxP 98 --maxEdges 400 -s 200000 --saveCls -v  > metagenomics/runs/biodegradation/{sample}_data/binning/metabat2/CONTIGS_MEGAHIT/metabat.log

#rule gtdbtk_metabat2:

gtdbtk classify_wf --genome_dir  metagenomics/runs/biodegradation/{sample}_data/binning/metabat2/CONTIGS_MEGAHIT/ --out_dir metagenomics/runs/biodegradation/{sample}_data/binning/gtdbtk_metabat2/  -x fa --cpus 30 --min_perc_aa 0.5 --force > metagenomics/runs/biodegradation/{sample}_data/binning/gtdbtk_metabat2/summary.txt

#rule bin_sanity:

Binsanity-wf -f metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT -l contigs.fasta -c metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth_avg_log.txt -o metagenomics/runs/biodegradation/{sample}_data/binning/binsanity/CONTIGS_MEGAHIT/ --binPrefix  final -p -3 -x 2500 --threads 45 

#rule bin_cvg_metabat2:

Scripts/summary_coverage_metabat.sh metagenomics/runs/biodegradation/{sample}_data/binning/metabat2/CONTIGS_MEGAHIT/ fa metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt metagenomics/runs/biodegradation/{sample}_data/binning/abundance.metabat.tsv

#rule checkM_metabat2:

checkm lineage_wf -f metagenomics/runs/biodegradation/{sample}_data/binning/checkM_metabat2/summary.txt -t  35 -x fa  metagenomics/runs/biodegradation/{sample}_data/binning/metabat2/CONTIGS_MEGAHIT/ metagenomics/runs/biodegradation/{sample}_data/binning/checkM_metabat2/ 

#rule maxbin:

run_MaxBin.pl -contig metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta -abund  metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth_avg.txt -out metagenomics/runs/biodegradation/{sample}_data/binning/maxbin/CONTIGS_MEGAHIT/bin -thread 35 -prob_threshold 0.9 -markerset 107 -min_contig_length 2500  -plotmarker  > metagenomics/runs/biodegradation/{sample}_data/binning/maxbin/CONTIGS_MEGAHIT/maxbin.log

#rule gc_prc_metabat2:

Scripts/computeGC.sh metagenomics/runs/biodegradation/{sample}_data/binning/metabat2/CONTIGS_MEGAHIT/ fa metagenomics/runs/biodegradation/{sample}_data/binning/gc_prc.metabat.tsv

#rule concoct:

concoct -l 2500 -i 600 -t 45 --coverage_file metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth_avg.txt --composition_file metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta    -b metagenomics/runs/biodegradation/{sample}_data/binning/concoct/CONTIGS_MEGAHIT/bin 

#rule gc_prc_binsanity:

Scripts/computeGC.sh metagenomics/runs/biodegradation/{sample}_data/binning/binsanity/CONTIGS_MEGAHIT/BinSanity-Final-bins/ fna metagenomics/runs/biodegradation/{sample}_data/binning/gc_prc.binsanity.tsv

#rule gtdbtk_maxbin:

gtdbtk classify_wf --genome_dir  metagenomics/runs/biodegradation/{sample}_data/binning/maxbin/CONTIGS_MEGAHIT/ --out_dir metagenomics/runs/biodegradation/{sample}_data/binning/gtdbtk_maxbin/  -x fasta --cpus 30 --min_perc_aa 0.5 --force  > metagenomics/runs/biodegradation/{sample}_data/binning/gtdbtk_maxbin/summary.txt

#rule bin_cvg_maxbin:

Scripts/summary_coverage_maxbin.sh metagenomics/runs/biodegradation/{sample}_data/binning/maxbin/CONTIGS_MEGAHIT/ fasta metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt metagenomics/runs/biodegradation/{sample}_data/binning/abundance.maxbin.tsv

#rule bin_cvg_binsanity:

Scripts/summary_coverage_bs.sh metagenomics/runs/biodegradation/{sample}_data/binning/binsanity/CONTIGS_MEGAHIT/BinSanity-Final-bins/ fna metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt metagenomics/runs/biodegradation/{sample}_data/binning/abundance.binsanity.tsv

#rule checkM_maxbin:

checkm lineage_wf -f metagenomics/runs/biodegradation/{sample}_data/binning/checkM_maxbin/summary.txt -t  35 -x fasta  metagenomics/runs/biodegradation/{sample}_data/binning/maxbin/CONTIGS_MEGAHIT/ metagenomics/runs/biodegradation/{sample}_data/binning/checkM_maxbin/ 

#rule extract_concoct_bins:

extract_fasta_bins.py --output_path  metagenomics/runs/biodegradation/{sample}_data/binning/concoct/CONTIGS_MEGAHIT/ metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta metagenomics/runs/biodegradation/{sample}_data/binning/concoct/CONTIGS_MEGAHIT/bin_clustering_gt2500.csv > metagenomics/runs/biodegradation/{sample}_data/binning/concoct/CONTIGS_MEGAHIT/concoct.log

#rule bins_to_table:

Scripts/tableBins.py

#rule checkM_binsanity:

checkm lineage_wf -f metagenomics/runs/biodegradation/{sample}_data/binning/checkM_binsanity/summary.txt -t  35 -x fna  metagenomics/runs/biodegradation/{sample}_data/binning/binsanity/CONTIGS_MEGAHIT/BinSanity-Final-bins/ metagenomics/runs/biodegradation/{sample}_data/binning/checkM_binsanity/ 

#rule gc_prc_maxbin:

Scripts/computeGC.sh metagenomics/runs/biodegradation/{sample}_data/binning/maxbin/CONTIGS_MEGAHIT/ fasta metagenomics/runs/biodegradation/{sample}_data/binning/gc_prc.maxbin.tsv

#rule das:

DAS_Tool -i metagenomics/runs/biodegradation/{sample}_data/binning/metabat2/CONTIGS_MEGAHIT/binTable.tsv,metagenomics/runs/biodegradation/{sample}_data/binning/maxbin/CONTIGS_MEGAHIT/binTable.tsv,metagenomics/runs/biodegradation/{sample}_data/binning/concoct/CONTIGS_MEGAHIT/binTable.tsv,metagenomics/runs/biodegradation/{sample}_data/binning/binsanity/CONTIGS_MEGAHIT/binTable.tsv -l metabat,maxbin,concoct,binsanity -c metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta -t 35 --write_bins  --dbDirectory /export/lv5/software/anaconda/2022.05/envs/metacascabel_c_env/share/das_tool-1.1.5-0/db/ --search_engine diamond  --duplicate_penalty 0.4 --megabin_penalty 0.4  -o metagenomics/runs/biodegradation/{sample}_data/binning/das/CONTIGS_MEGAHIT/DasOut > metagenomics/runs/biodegradation/{sample}_data/binning/das/CONTIGS_MEGAHIT/das.log 2>&1

#rule checkM_concoct:

checkm lineage_wf -f metagenomics/runs/biodegradation/{sample}_data/binning/checkM_concoct/summary.txt -t  35 -x fa  metagenomics/runs/biodegradation/{sample}_data/binning/concoct/CONTIGS_MEGAHIT/ metagenomics/runs/biodegradation/{sample}_data/binning/checkM_concoct/ 

#rule bin_cvg_concoct:

Scripts/summary_coverage_concoct.sh metagenomics/runs/biodegradation/{sample}_data/binning/concoct/CONTIGS_MEGAHIT/ fa metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt metagenomics/runs/biodegradation/{sample}_data/binning/abundance.concoct.tsv

#rule gc_prc_concoct:

Scripts/computeGC.sh metagenomics/runs/biodegradation/{sample}_data/binning/concoct/CONTIGS_MEGAHIT/ fa  metagenomics/runs/biodegradation/{sample}_data/binning/gc_prc.concoct.tsv

#rule rename_Final_bins:

Scripts/renameFinalBins.sh metagenomics/runs/biodegradation/{sample}_data/binning/das/CONTIGS_MEGAHIT/DasOut_DASTool_bins/  fa MBL1 metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins/ metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins/new_names.txt

#rule bin_cvg_das:

Scripts/summary_coverage_das.sh metagenomics/runs/biodegradation/{sample}_data/binning/das/CONTIGS_MEGAHIT/DasOut_DASTool_bins/ fa metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt metagenomics/runs/biodegradation/{sample}_data/binning/abundance.das.tsv

#rule checkM_das:

checkm lineage_wf -f metagenomics/runs/biodegradation/{sample}_data/binning/checkM_das/summary.txt -t  35 -x fa  metagenomics/runs/biodegradation/{sample}_data/binning/das/CONTIGS_MEGAHIT/DasOut_DASTool_bins/ metagenomics/runs/biodegradation/{sample}_data/binning/checkM_das/ 

#rule get_unbinned_contigs:

cat metagenomics/runs/biodegradation/{sample}_data/binning/das/CONTIGS_MEGAHIT/DasOut_DASTool_summary.tsv | cut -f1 | grep -v -F -w -f - metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta | grep "^>" | sed 's/^>//' > metagenomics/runs/biodegradation/{sample}_data/unbinned/unbinned_contigs_list.txt

#rule gc_prc_das:

Scripts/computeGC.sh metagenomics/runs/biodegradation/{sample}_data/binning/das/CONTIGS_MEGAHIT/DasOut_DASTool_bins/ fa metagenomics/runs/biodegradation/{sample}_data/binning/gc_prc.das.tsv

#rule gtdbtk_das:

gtdbtk classify_wf --genome_dir  metagenomics/runs/biodegradation/{sample}_data/binning/das/CONTIGS_MEGAHIT/DasOut_DASTool_bins/ --out_dir metagenomics/runs/biodegradation/{sample}_data/binning/gtdbtk_das/  -x fa --cpus 30 --min_perc_aa 0.5 --force > metagenomics/runs/biodegradation/{sample}_data/binning/gtdbtk_das/summary.txt 

#rule create_unbinned_fasta:

seqtk subseq metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/contigs.fasta metagenomics/runs/biodegradation/{sample}_data/unbinned/unbinned_contigs_list.txt > metagenomics/runs/biodegradation/{sample}_data/unbinned/unbinned.fasta

#rule coverage_contigs_final_bins:

cat  metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins/*.fna  | grep "^>" | sed 's/>// ; s/ /	/g' |  awk -F"\t" 'NR==FNR{h[$2]=$1;next}BEGIN{OFS="\t"; FS="\t"}{if(h[$1]){print h[$1],$3}}' - metagenomics/runs/biodegradation/{sample}_data/bwa-mem/CONTIGS_MEGAHIT_depth.txt > metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins/contig_coverage.txt

#rule summarize_gtdbtk:

Scripts/summary_gtdb.sh metagenomics/runs/biodegradation/{sample}_data/binning/gtdbtk_\*/summary.txt

#rule summarize_checkM:

Scripts/summary_checkM.sh metagenomics/runs/biodegradation/{sample}_data/binning/checkM_\*/summary.txt

#rule merge_checkM_gtdb_results:

cat metagenomics/runs/biodegradation/{sample}_data/binning/summary_gtdb.tsv | awk -F"\t" 'BEGIN{OFS="\t"} NR==FNR{if(NR==1){ header="GTDB_"$3"\tGTDB_"$4"\tGTDB_"$5"\tGTDB_"$6} else{bin[$1$2]=$3"\t"$4"\t"$5"\t"$6};next}  BEGIN{OFS="\t"} {if(FNR==1){print $0,header} else{if(bin[$1$2]){print $0,bin[$1$2]}else{print $0,"Filtered","-","-","-"}}}' - metagenomics/runs/biodegradation/{sample}_data/binning/summary_checkM.tsv > metagenomics/runs/biodegradation/{sample}_data/binning/summary.tsv
Would remove temporary output metagenomics/runs/biodegradation/{sample}_data/binning/summary_checkM.tsv
Would remove temporary output metagenomics/runs/biodegradation/{sample}_data/binning/summary_gtdb.tsv

#rule summarize_coverage:

cat metagenomics/runs/biodegradation/{sample}_data/binning/abundance*.tsv | grep  -v num_contigs | awk -F "\t" 'FNR==NR{if(NR>1){h[$1$2]=$3"\t"$4"\t"$5};next } BEGIN{OFS="\t"} {if(FNR==1){print $0,"num_contigs","total_length","avg_depth" }else{print $0,h[$1$2]} }'  - metagenomics/runs/biodegradation/{sample}_data/binning/summary.tsv > metagenomics/runs/biodegradation/{sample}_data/binning/summary_abundance.tsv

#rule summarize_gc_prc:

cat metagenomics/runs/biodegradation/{sample}_data/binning/gc_prc*.tsv |  awk -F "\t" 'FNR==NR{if(NR>1){h[$1$2]=$3};next } BEGIN{OFS="\t"} {if(FNR==1){print $0,"avg_gc" }else{print $0,h[$1$2]} }'  - metagenomics/runs/biodegradation/{sample}_data/binning/summary_abundance.tsv > metagenomics/runs/biodegradation/{sample}_data/binning/summary_abundance_coverage.tsv

#rule summarize_final_bins:

cat metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins/new_names.txt |  awk -F "\t" 'FNR==NR{ parts=split($2,n,".");name=n[1]; for(i=2;i<parts;i++){name=name"."n[i]}; nparts=split($3,nn,".");nname=nn[1]; for(i=2;i<nparts;i++){nname=nname"."nn[i]}; h[$1name]=nname;next } BEGIN{OFS="\t"} {if(FNR==1){print "New_BinID",$0}else if(h[$1$2]){print h[$1$2],$0} }'  - metagenomics/runs/biodegradation/{sample}_data/binning/summary_abundance_coverage.tsv > metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins.summary.tsv

#rule backup_bin_tables:

if [ ! -d "/export/lv9/projects/MBL1/bin_tables" ]; then     mkdir /export/lv9/projects/MBL1/bin_tables ; echo "Bin table folder created..." ;fi;for file in metagenomics/runs/biodegradation/{sample}_data/binning/*/CONTIGS_MEGAHIT/binTable.tsv;do  sample=$(echo $file | awk -F'/' '{gsub("_data","",$4); print $4}'); method=$(echo $file | awk -F'/' '{print $6}'); cp $file /export/lv9/projects/MBL1/bin_tables/binTable_${sample}_${method}.tsv;done;echo "Bin tables backedup at: "  /export/lv9/projects/MBL1/bin_tables > metagenomics/runs/biodegradation/{sample}_data/binning/backup.tables.log

#rule backup_final_bins:

if [ ! -d "/export/lv9/projects/MBL1/bins/" ]; then     mkdir /export/lv9/projects/MBL1/bins/ ; echo "Bin folder created..." ;fi;for file in metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins/*.fna;do  sample=$(echo $file | awk -F'/' '{gsub("_data","",$4); print $4}'); fname=$(echo $file | awk  -F'/' '{print $NF".gz"}');if [ ! -d "/export/lv9/projects/MBL1/bins/MBL1" ]; then     mkdir /export/lv9/projects/MBL1/bins/MBL1 ; echo "Sample bin folder created..." ;fi; gzip -c $file  > /export/lv9/projects/MBL1/bins/MBL1/${fname};done;cp metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins/*.txt /export/lv9/projects/MBL1/bins/MBL1/ ;cp metagenomics/runs/biodegradation/{sample}_data/binning/FinalBins.summary.tsv /export/lv9/projects/MBL1/bins/FinalBins.MBL1.summary.tsv ;echo "Bins backedup at: "  /export/lv9/projects/MBL1/bins/MBL1 > metagenomics/runs/biodegradation/{sample}_data/binning/backup.bins.log

#rule back_up:

cat metagenomics/runs/biodegradation/{sample}_data/trimmed/backup.log metagenomics/runs/biodegradation/{sample}_data/assembly_MEGAHIT/backup.log metagenomics/runs/biodegradation/{sample}_data/bwa-mem/backup.log metagenomics/runs/biodegradation/{sample}_data/binning/backup.bins.log metagenomics/runs/biodegradation/{sample}_data/binning/backup.tables.log >  metagenomics/runs/biodegradation/{sample}_data/backup.log


