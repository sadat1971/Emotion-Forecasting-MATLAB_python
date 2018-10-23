directory$ = "/home/sadat/kimlab/Data/IEMOCAP_full_release/Session1/sentences/wav/Ses01M_script01_3/"

outdir$ = "/home/sadat/kimlab/Sadat/IEMOCAP_forcasting/audio_features/s1/"

extension$ = ".wav"

 

Create Strings as file list... list 'directory$'*'extension$'

number_files = Get number of strings

 

for a from 1 to number_files

                select Strings list

                current_file$ = Get string... 'a'

                Read from file... 'directory$''current_file$'

                object_name$ = selected$("Sound")

 

                To Intensity... 100 0.025 no

                Down to Matrix

                Transpose

                Write to matrix text file... 'outdir$'/'object_name$'.intensity

                Remove

                select Matrix 'object_name$'

                Remove

                select Intensity 'object_name$'

                Remove

 

                select Sound 'object_name$'

                To Pitch (ac)... 0.025 30 15 no 0.03 0.45 0.01 0.35 0.14 600

                select Pitch 'object_name$'

                Smooth... 10

                Interpolate

                To Matrix

                Transpose

                Write to matrix text file... 'outdir$'/'object_name$'.pitch

                Remove

                select Matrix 'object_name$'

                Remove

                select Pitch 'object_name$'

                Remove

                select Pitch 'object_name$'

                Remove

                select Pitch 'object_name$'

                Remove


 

                select Sound 'object_name$'

                To MFCC... 12 0.050 0.025 100 100 0

                To Matrix

                Transpose

                Write to matrix text file... 'outdir$'/'object_name$'.mfcc

                Remove

                select Matrix 'object_name$'

                Remove

                select MFCC 'object_name$'

                Remove

 

                select Sound 'object_name$'

                To MelFilter... 0.050 0.025 100 100 0

                To Matrix

                Transpose

                Write to matrix text file... 'outdir$'/'object_name$'.mfb

                Remove

                select Matrix 'object_name$'

                Remove

                select MelFilter 'object_name$'

                Remove

                select Sound 'object_name$'

                Remove

endfor
