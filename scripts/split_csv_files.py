import pandas as pd

# Caminho do arquivo CSV
input_file = '/Users/gsantos/deel_takehome/invoices.csv'

# Número de partes desejadas
num_parts = 20

# Lendo o arquivo CSV
chunksize = sum(1 for line in open(input_file)) // num_parts
chunks = pd.read_csv(input_file, chunksize=chunksize)

# Salvando cada parte em um arquivo separado
for i, chunk in enumerate(chunks):
    chunk.to_csv(f'csv_files/parte_{i+1}.csv', index=False)