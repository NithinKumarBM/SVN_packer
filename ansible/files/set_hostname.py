import subprocess
import random
import string
import sys

def generate_random_string(length=6):
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))

def set_hostname(base_hostname, domain):
    random_string = generate_random_string()
    full_hostname = f"{base_hostname}-{random_string}.{domain}"
    console_hostname = f"{base_hostname}-{random_string}"

    # Set the full hostname inside the server
    subprocess.run(['sudo', 'hostnamectl', 'set-hostname', full_hostname], check=True)

    # Update /etc/hosts for local resolution
    with open('/etc/hosts', 'r') as file:
        hosts = file.readlines()

    with open('/etc/hosts', 'w') as file:
        for line in hosts:
            if '127.0.0.1' in line:
                file.write(f"127.0.0.1   {full_hostname} {base_hostname}\n")
            else:
                file.write(line)

    # Set the short hostname for AWS Console
    subprocess.run(['sudo', 'hostnamectl', 'set-hostname', console_hostname, '--transient'], check=True)

    # Set the console_hostname as an environment variable permanently
    with open('/etc/environment', 'a') as env_file:
        env_file.write(f'CONSOLE_HOSTNAME={console_hostname}\n')

    print(f"Hostname inside server set to: {full_hostname}")
    print(f"Hostname in AWS console set to: {console_hostname}")
    print(f"Environment variable CONSOLE_HOSTNAME set to: {console_hostname}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 set_hostname.py <base_hostname> <domain>")
        sys.exit(1)

    base_hostname = sys.argv[1]
    domain = sys.argv[2]
    set_hostname(base_hostname, domain)