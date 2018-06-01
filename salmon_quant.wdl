workflow salmon_quant{
    File index_archive
    String index_archive_dirname
    String lib_type
    File reads_1
    File reads_2
    String out_dir
    Int? ncpu
    Boolean useVBOpt=false
    # following two are mutually exclusive
    Int? numBootstraps
    Int? numGibbsSamples
    Int? memGB
    String? salmon_disks

    call salmon { input:
        index_archive = index_archive,
        index_archive_dirname = index_archive_dirname,
        lib_type = lib_type,
        read_1 = reads_1,
        read_2 = reads_2,
        out_dir = out_dir,
        ncpu = ncpu,
        memGB = memGB,
        numBootstraps = numBootstraps,
        numGibbsSamples = numGibbsSamples,
        useVBOpt = useVBOpt,
        salmon_disks = salmon_disks
    }
}


    task salmon {
        File index_archive
        String index_archive_dirname
        String lib_type
        File read_1
        File read_2
        String out_dir
        Int? ncpu
        Int? memGB
        Boolean useVBOpt
        Int? numBootstraps
        Int? numGibbsSamples
        String? salmon_disks

        command {
            tar -xzvf ${index_archive} 
            salmon quant \
                ${"-i " + index_archive_dirname} \
                ${"-l " + lib_type} \
                ${"-p " + ncpu} \
                -1 ${read_1} \
                -2 ${read_2} \
                ${if useVBOpt then "--useVBOpt" else ""} \
                ${"--numBootstraps " + numBootstraps} \
                ${"--numGibbsSamples " + numGibbsSamples} \
                ${"-o " + out_dir}
        }

        output {
            File quants = glob("${out_dir}/*.sf")[0]
            File info = glob("${out_dir}/*.json")[0]

        }

        runtime {
            docker: "combinelab/salmon:latest"
            cpu: select_first([ncpu,4])
            memory: "${select_first([memGB,8])} GB"
            disks: select_first([salmon_disks, "local-disk 100 HDD"])
        }        
    }
