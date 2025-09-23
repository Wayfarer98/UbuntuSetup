# Setup guide for new fresh Ubuntu install

1. run:

   ```
   sudo visudo
   ```

   Find the line `%sudo ALL=(ALL) ALL`
   Replace with `%sudo ALL=(ALL) NOPASSWD:ALL`

2. run:

   ```
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/Wayfarer98/UbuntuSetup/master/setup.sh)"
   ```

   Follow the prompt

3. To finish the setup, reboot the system
