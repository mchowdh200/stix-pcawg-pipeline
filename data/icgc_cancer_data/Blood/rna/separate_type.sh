import csv

input_file = 'repository_1684876633.tsv'  # Replace with the actual filename of your TSV file

normal_file = 'blood_rna_normal_samples.tsv'
tumor_file = 'blood_rna_tumor_samples.tsv'

with open(input_file, 'r', newline='') as file:
    reader = csv.reader(file, delimiter='\t')
    header = next(reader)  # Read the header line

    normal_data = []
    tumor_data = []

    for row in reader:
        sample_type = row[3]  # Assuming the sample type is in the fourth column
        if sample_type == 'Normal':
            normal_data.append(row)
        elif sample_type == 'Tumor':
            tumor_data.append(row)

with open(normal_file, 'w', newline='') as file:
    writer = csv.writer(file, delimiter='\t')
    writer.writerow(header)
    writer.writerows(normal_data)

with open(tumor_file, 'w', newline='') as file:
    writer = csv.writer(file, delimiter='\t')
    writer.writerow(header)
    writer.writerows(tumor_data)

print("Separation completed. Normal samples saved in '{}' and tumor samples saved in '{}'.".format(normal_file, tumor_file))

