import os
import shutil
import glob
import argparse

# Parse command-line argument for test_size
parser = argparse.ArgumentParser(description='Run retraining with a specified test_size.')
parser.add_argument(
    '--test_size', 
    type=float, 
    required=True, 
    help='Example: --test_size 0.7'
)
args = parser.parse_args()
test_size = args.test_size

# Define the parameters for retraining
retrain_cmd     = "python3 retrain.py 500 500 {} > {}"
mv_png          = "adapter-error-summary.png"
new_png         = "adapter-error-summary_{}_{}.png"
sim_txt         = "adapter_dnMAPE_below_5_{:02d}_{}.txt"

#####################################
# Loop for 2*500 epochs to          #
# achieve atleast 5% dnMAPE score   #
# with maximum test_size            #
#                                   #
#####################################
for i in range(15):
    iteration_folder = f"q3_it_{i:02d}_{int(test_size*100)}"
    if not os.path.exists(iteration_folder):
        os.makedirs(iteration_folder)

    sim_filename = sim_txt.format(i, int(test_size*100))
    
    command = retrain_cmd.format(test_size, sim_filename)
    print(f"Executing: {command}")
#    break
    os.system(command)
    
    new_png_name = new_png.format(i, int(test_size*100))
    mv_cmd = f"mv {mv_png} {new_png_name}"
    print(f"Renaming: {mv_png} to {new_png_name}")
    os.system(mv_cmd)
    shutil.move(new_png_name, iteration_folder)
    shutil.move(sim_filename, iteration_folder)

    # Move all generated files to the iteration folder        
    pt_files = glob.glob('retrain*.png')  
    for pt_file in pt_files:
        shutil.move(pt_file, iteration_folder)
        print(f"Moved {pt_file} to {iteration_folder}")
        
    print(f"Listing contents of {iteration_folder}:")
    os.system(f"ls {iteration_folder}")

print("Script execution completed.")

