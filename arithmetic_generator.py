import random
import argparse


def generate_latex(n_digit, n_page, page_offset):
    """
    Generate LaTeX code for arithmetic worksheets.
    
    Parameters:
    - n_digit: number of digits for each operand
    - n_page: number of pages to generate
    - page_offset: starting page number
    """
    
    # LaTeX document header
    latex_content = r"""\documentclass[12pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[margin=2cm]{geometry}
\usepackage{multicol}
\usepackage{fancyhdr}
\usepackage{CJKutf8}

\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\cfoot{\thepage}

\setlength{\parindent}{0pt}
\setlength{\columnsep}{2cm}

\begin{document}
\begin{CJK}{UTF8}{mj}

"""
    
    # Generate pages
    for page_num in range(n_page):
        current_page = page_offset + page_num
        
        # Date field at top
        latex_content += r"\noindent 날짜: \underline{\hspace{5cm}}" + "\n\n"
        latex_content += r"\vspace{1cm}" + "\n\n"
        
        # Start 2-column layout with larger font
        latex_content += r"\begin{multicols}{2}" + "\n"
        latex_content += r"\Large" + "\n\n"
        
        # Generate 10 problems
        for i in range(1, 11):
            # Generate random numbers with n_digit digits
            min_val = 10 ** (n_digit - 1)
            max_val = 10 ** n_digit - 1
            
            A = random.randint(min_val, max_val)
            B = random.randint(min_val, max_val)
            
            # Format: numbered problem with blank for answer
            latex_content += f"\\noindent {i}. \\quad ${A} + {B} = $ \\underline{{\\hspace{{3cm}}}}\n\n"
            latex_content += r"\vspace{0.8cm}" + "\n\n"
        
        # End 2-column layout
        latex_content += r"\end{multicols}" + "\n\n"
        
        # Add page break if not the last page
        if page_num < n_page - 1:
            latex_content += r"\newpage" + "\n\n"
    
    # LaTeX document footer
    latex_content += r"""
\end{CJK}
\end{document}
"""
    
    return latex_content


def main():
    parser = argparse.ArgumentParser(description='Generate arithmetic worksheets for preschool children')
    parser.add_argument('n_digit', type=int, help='Number of digits for operands')
    parser.add_argument('n_page', type=int, help='Number of pages to generate')
    parser.add_argument('page_offset', type=int, help='Starting page number')
    parser.add_argument('-o', '--output', type=str, default='worksheet.tex', 
                        help='Output filename (default: worksheet.tex)')
    
    args = parser.parse_args()
    
    # Validate inputs
    if args.n_digit < 1:
        print("Error: n_digit must be at least 1")
        return
    if args.n_page < 1:
        print("Error: n_page must be at least 1")
        return
    if args.page_offset < 1:
        print("Error: page_offset must be at least 1")
        return
    
    # Generate LaTeX content
    latex_code = generate_latex(args.n_digit, args.n_page, args.page_offset)
    
    # Write to file
    with open(args.output, 'w', encoding='utf-8') as f:
        f.write(latex_code)
    
    print(f"LaTeX file generated: {args.output}")
    print(f"Pages: {args.n_page} (starting from page {args.page_offset})")
    print(f"Digit count: {args.n_digit}")


if __name__ == "__main__":
    main()

