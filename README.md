# Setup guide for new fresh Ubuntu install

1. run:  
    ```
    sudo visudo
    ```
    Find the line ``` %sudo ALL=(ALL) ALL ```
    Replace with ``` %sudo ALL=(ALL) NOPASSWD:ALL ```

2. run:
    ```
    sh -C "$(curl -fsSL https://raw.githubusercontent.com/Wayfarer98/UbuntuSetup/master/setup.sh)"
    ```
    Follow the prompt

3. run:
    ```
    sh -C "$(curl -fsSL https://raw.githubusercontent.com/Wayfarer98/UbuntuSetup/master/configure.sh)"
    ```

4. If the program terminated without error, you are all set up
