import os
import shutil

# Set the source and destination paths
source_path = r'C:\Users\DELL\OneDrive\Desktop\IC project\GIS\Digimap_download'
destination_path = r'C:\Users\DELL\OneDrive\Desktop\IC project\GIS\Digimap_for_combine'

# Loop through each folder
for folder_name in range(5034721, 5034864):
    folder_name_str = str(folder_name)
    folder_path = os.path.join(source_path, 'mastermap_building_heights_' + folder_name_str)

    # Look for subfolders named 'tl' or 'tq'
    for subfolder_name in ['tl', 'tq']:
        subfolder_path = os.path.join(folder_path, subfolder_name)

        # Copy the subfolder to the destination folder
        if os.path.exists(subfolder_path):
            new_folder_path = os.path.join(destination_path, folder_name_str)
            shutil.copytree(subfolder_path, new_folder_path)

# Now move subfolders out from the newly creatded folder
# Set the source and destination paths
source_path = r'C:\Users\DELL\OneDrive\Desktop\IC project\GIS\Digimap_for_combine'
destination_path = r'C:\Users\DELL\OneDrive\Desktop\IC project\GIS\Digimap_for_combine2'

for folder_name in range(5034721, 5034864):
    folder_name_str = str(folder_name)
    folder_path = os.path.join(source_path, folder_name_str)

    for subfolder_name in os.listdir(folder_path):
        subfolder_path = os.path.join(folder_path, subfolder_name)

        # Create the destination subfolder since it doesn't exist
        destination_path1 = os.path.join(destination_path, subfolder_name)
        os.makedirs(destination_path1)

            # Copy the subfolder contents to the destination folder
            for file_name in os.listdir(subfolder_path):
                file_path = os.path.join(subfolder_path, file_name)
                destination_path2 = os.path.join(destination_path1, file_name)
                shutil.copy(file_path, destination_path2)