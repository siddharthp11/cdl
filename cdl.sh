#!/bin/bash

function cdl(){
    local long_path=1
    
    if [[ ! -z "$1" ]]; then
        long_path=0
    fi
    
    function cdl_main(){
        local dir=${1:-$PWD}
        local files=()
        readarray -t files < <(ls "$dir")
        length=${#files[@]}
        
        i=0
        while true; do
            if [[ ! $length -eq 0 ]]; then cdl_print ${files[i]}
            else cdl_print "nothing here"
            fi
    
            read -s -n 1 input
            if [[ $input == "q" ]]; then cdl_force_quit
            elif [[ $input == "d" ]]; then
                cdl_finish
                break
            elif [[ $input == "l" ]]; then
                echo -e ""
                echo -e $(ls "$dir")
            elif [[ $input == "p" ]]; then
                echo -e ""
                echo -e $PWD
            elif [[ $input == "h" ]]; then cdl_help
            elif [[ $input == "b" ]]; then
                cd ..
                cdl_main
                break
            fi
            
            if [[ ! $length -eq 0 ]]; then
            
                if [[ $input == "[" ]]; then ((i=(i+1)%length))
                elif [[ $input == "]" ]]; then
                    if [[ i -eq 0 ]]; then ((i=length-1))
                    else ((i=i-1))
                    fi
                elif [[ -z $input ]]; then
                    if [[ -d "${files[i]}" ]]; then
                        cd ${files[i]}
                        cdl_main
                        break
                    else cdl_print "not dir"
                    fi
                fi
            fi
            done
    }

    function cdl_help(){
        printf "
    CDL: Command line tool for quick navigation.
        enter ->    cd into folder
        [] ->       cycle up/down in dir
        b   ->      cd to previous dir
        l ->        list files in dir
        d ->        done
        q ->        force quit
        h ->        help
        
        "
    }

    function cdl_print(){
        
        total_width=40
        padded_item=$(printf "%-${total_width}s" "$1")
        
        if [[ $long_path -eq 1 ]]; then echo -ne "\r(cdl):~$PWD/$padded_item"
        else echo -ne "\r(cdl):~/$padded_item"
        fi
    }
    
    function cdl_finish(){
        echo -e ""
    }
    
    function cdl_force_quit() {
        tput cnorm
        exit
    }
        

    tput civis
    trap 'cdl_force_quit' INT
    
    cdl_help
    cdl_main
    
    trap - INT
    tput cnorm


}


