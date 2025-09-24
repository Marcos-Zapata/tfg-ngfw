import os, time
from scapy.all import sniff, wrpcap
from dotenv import load_dotenv


IFACE = os.getenv("IFACE", "eth0")
PCAP_PATH = "/data/capture_%d.pcap" % int(time.time())
LOG = "./logs/capture.log"


buf = []

def on_pkt(pkt):
    buf.append(pkt)
    if len(buf) >= 200:  # escribe cada 200 paquetes
        wrpcap(PCAP_PATH, buf, append=True)
        del buf[:]

if __name__ == "__main__":
    os.makedirs("./logs", exist_ok=True)
    with open(LOG, "a") as f:
        f.write(f"Sniffer iniciado en iface={IFACE}, guardando en {PCAP_PATH}\n")
    sniff(prn=on_pkt, store=False, iface=IFACE)
