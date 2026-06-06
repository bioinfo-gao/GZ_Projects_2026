# Gene Filtering Methods Documentation

## Overview
This document describes the two-tiered approach implemented in `4A_run_DE_PCA_and_with_selection_and_filterfinal.R` for filtering genes during RNA-seq differential expression analysis.

## Primary Method: Annotation-Based Filtering

### When Used
- Gene annotation Excel file exists at expected location
- File can be successfully read using `readxl` package
- Required columns (`gene_id`, `gene_name`, `gene_type`) are present

### Filtering Logic
1. **Ribosomal Gene Removal**:
   - Genes with `gene_type` containing "ribosomal" (case-insensitive)
   - Genes with `gene_name` starting with ribosomal patterns: `RPL`, `RPS`, `MRPL`, `MRPS`

2. **Non-Protein Coding Gene Removal**:
   - Only retains genes where `gene_type == "protein_coding"`
   - This is the most accurate method as it uses official gene biotype classification

### Advantages
- **High accuracy**: Uses official gene annotations from authoritative sources
- **Comprehensive**: Covers all ribosomal and non-coding genes regardless of naming conventions
- **Future-proof**: Adapts to new gene discoveries and updated annotations

## Fallback Method: Regex Pattern Matching

### When Used
- Gene annotation file not found
- File cannot be read (corrupted, wrong format, etc.)
- Required columns missing from annotation file
- Any error occurs during annotation-based processing

### Filtering Logic

#### Ribosomal Gene Patterns
```regex
^RPL|^RPS|^MRPL|^MRPS|^RPLP|^RPSA|^RACK|^RAN|Ribosomal|ribosomal
```
- `^RPL`, `^RPS`: Cytoplasmic ribosomal proteins (large/small subunits)
- `^MRPL`, `^MRPS`: Mitochondrial ribosomal proteins (large/small subunits)
- `^RPLP`: Ribosomal protein lateral stalk
- `^RPSA`: Ribosomal protein SA (37kDa laminin receptor)
- `^RACK`: Receptor for activated C kinase
- `^RAN`: Ras-related nuclear protein
- Case-insensitive matching for "Ribosomal"/"ribosomal"

#### Non-Coding RNA Patterns
```regex
^MT-|^MT_|^MTRNR|^MTRF|^MTTF|^MTTS|^MTTL|^MTTH|^MTTD|^MTTC|^MTTA|
^SNORD|^SNORA|^RNU|^U[0-9]|^MALAT|^NEAT|^XIST|^HOTAIR|
^MIR|^miR|^let-|^lincRNA|^LINC|^LOC[0-9]|^RP[0-9]|
pseudogene|Pseudogene|antisense|Antisense
```

**Categories covered**:
- **Mitochondrial genes**: `MT-`, `MT_`, `MTRNR`, etc.
- **Small nucleolar RNAs**: `SNORD`, `SNORA`
- **Small nuclear RNAs**: `RNU`, `U[0-9]`
- **Long non-coding RNAs**: `MALAT`, `NEAT`, `XIST`, `HOTAIR`, `lincRNA`, `LINC`
- **MicroRNAs**: `MIR`, `miR`, `let-`
- **Pseudogenes**: `LOC[0-9]`, `RP[0-9]`, explicit "pseudogene"
- **Antisense RNAs**: "antisense", "Antisense"

### Advantages
- **No external dependencies**: Works with just gene names
- **Immediate availability**: Doesn't require annotation files
- **Broad coverage**: Captures common naming conventions

### Limitations
- **Incomplete coverage**: May miss genes with non-standard names
- **False positives**: Might incorrectly filter some protein-coding genes
- **Maintenance required**: Needs updates for new gene naming conventions

## Implementation Strategy

### Error Handling
The implementation uses robust error handling:
- `tryCatch()` blocks handle file reading errors
- Column existence checks prevent runtime errors
- Graceful fallback ensures analysis continues even if primary method fails

### Combined Approach
Even when using annotation-based filtering, regex patterns are applied as an additional safety net to catch any ribosomal genes that might be missed in the annotation.

## Usage Recommendations

1. **Always provide gene annotation file** when possible for highest accuracy
2. **Verify annotation file structure** matches expected columns before analysis
3. **Review filtering logs** to understand which method was used and how many genes were filtered
4. **Update regex patterns** periodically to include newly discovered non-coding RNA families

## Example Log Output
```
✅ Gene annotation file loaded successfully
✅ Applied annotation-based filtering: 18542 genes retained
✅ After low count filtering: 15234 genes retained
✅ Final gene count for analysis: 15234
```

vs fallback:
```
⚠️  Gene annotation file not found, using regex filtering
✅ Original gene count: 58432
✅ After gene type filtering: 21456 genes retained
✅ After low count filtering: 17823 genes retained
✅ Final gene count for analysis: 17823
```