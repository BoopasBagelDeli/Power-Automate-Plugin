from setuptools import setup, find_packages

setup(
    name="power-automate",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.9",
    install_requires=[
        # Add your dependencies here
    ],
    author="Your Organization",
    author_email="support@company.com",
    description="Microsoft 365 Copilot Plugin - power-automate",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/power-automate",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
)

