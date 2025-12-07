import random
import yaml


def generate_number(digits):
    """Generate a random number with the specified number of digits."""
    if digits < 1:
        raise ValueError("Number of digits must be at least 1")
    min_val = 10 ** (digits - 1)
    max_val = 10**digits - 1
    return random.randint(min_val, max_val)


def generate_problem(problem_config):
    """Generate a single arithmetic problem based on configuration."""
    p_type = problem_config.get("type", "addition")
    operands_digits = problem_config.get("operands", [1, 1])

    nums = [generate_number(d) for d in operands_digits]

    if p_type == "addition":
        return f"{nums[0]} + {nums[1]} ="
    elif p_type == "subtraction":
        # Ensure positive result for subtraction if needed, or just simple subtraction
        # For preschool, usually A - B where A >= B
        # But for now, just implementing basic structure
        return f"{nums[0]} - {nums[1]} ="
    elif p_type == "multiplication":
        return f"{nums[0]} \\times {nums[1]} ="
    elif p_type == "division":
        return f"{nums[0]} \\div {nums[1]} ="
    
    return f"{nums[0]} + {nums[1]} ="


def generate_latex(config):
    """
    Generate LaTeX code for arithmetic worksheets based on configuration.
    """
    n_page = config["n_page"]
    page_offset = config["page_offset"]
    problems_config = config["problems"]
    
    # Check if questions_per_page varies by problem type
    detailed_counts = any("questions_per_page" in p for p in problems_config)
    
    if detailed_counts:
        total_questions = sum(p.get("questions_per_page", 0) for p in problems_config)
    else:
        total_questions = config.get("questions_per_page", 20)

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

    # Set starting page number
    latex_content += f"\\setcounter{{page}}{{{page_offset}}}\n\n"

    # Generate pages
    for page_num in range(n_page):
        # Prepare list of problem configs for this page
        current_page_problems_config = []
        if detailed_counts:
            for p_conf in problems_config:
                count = p_conf.get("questions_per_page", 0)
                current_page_problems_config.extend([p_conf] * count)
            # Shuffle so different problem types are mixed
            random.shuffle(current_page_problems_config)
        else:
            # Randomly sample from provided types for the whole page
            current_page_problems_config = [random.choice(problems_config) for _ in range(total_questions)]

        # Date field at top
        latex_content += r"\noindent 날짜: \underline{\hspace{5cm}}" + "\n\n"
        latex_content += r"\vspace{1cm}" + "\n\n"

        # Start 2-column layout with larger font
        latex_content += r"\begin{multicols}{2}" + "\n"
        latex_content += r"\Large" + "\n\n"

        # Generate problems per page
        for i, p_config in enumerate(current_page_problems_config, 1):
            problem_str = generate_problem(p_config)

            # Format: numbered problem with blank for answer
            latex_content += f"\\noindent {i}. \\quad ${problem_str}$ \\underline{{\\hspace{{3cm}}}}\n\n"
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
    try:
        with open("config.yaml", "r", encoding="utf-8") as f:
            config_data = yaml.safe_load(f)
    except FileNotFoundError:
        print("Error: config.yaml not found.")
        return
    except yaml.YAMLError as exc:
        print(f"Error parsing config.yaml: {exc}")
        return

    if "generations" not in config_data:
        print("Error: 'generations' key not found in config.yaml")
        return

    for gen_config in config_data["generations"]:
        output_file = gen_config.get("output", "worksheet.tex")
        print(f"Generating {output_file}...")
        
        try:
            latex_code = generate_latex(gen_config)
            
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(latex_code)
            print(f"  - Pages: {gen_config.get('n_page')}")
            print(f"  - Start Page: {gen_config.get('page_offset')}")
            print("  - Done.")
            
        except Exception as e:
            print(f"Error generating {output_file}: {e}")


if __name__ == "__main__":
    main()
