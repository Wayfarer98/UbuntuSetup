# Setup guide for new fresh Ubuntu install

1. run:  
    ```
    sudo visudo
    ```
    Find the line ``` %admin ALL=(ALL) ALL ```
    Replace with ``` %admin ALL=(ALL) NOPASSWD:ALL ```

2. run:
    ```
    setup.sh
    ```
    Follow the prompt

3. If you installed vscode, please set this up as you normally would.

4. If the program terminated without error, you are all set up