#include <omnetpp.h>
#include <string.h>
#include "inet/linklayer/ethernet/basic/EthernetEncapsulation.h"
#include "inet/linklayer/ethernet/basic/EthernetMac.h"
#include "inet/common/TagBase.h"
#include "inet/physicallayer/wired/ethernet/EthernetPhyHeader_m.h"
#include "inet/linklayer/ieee8021q/Ieee8021qTagHeader_m.h"
#include "inet/transportlayer/udp/UdpHeader_m.h"
#include <inet/transportlayer/contract/udp/UdpSocket.h>
#include <inet/networklayer/common/L3AddressResolver.h>
#include "inet/networklayer/ipv4/Ipv4Header_m.h"
#include "inet/linklayer/common/InterfaceTag_m.h"
#include "inet/networklayer/arp/ipv4/GlobalArp.h"
#include "inet/networklayer/common/MyTag.h"
using namespace inet;
using namespace omnetpp;
using namespace std;
class TSN5GTranslator : public cSimpleModule{
        int localPort;
        int destPort;
        L3Address destAddress;
        UdpSocket socket;
        virtual void initialize() override;
        virtual void handleMessage(cMessage *msg) override;
        void sendPacket(Packet *pkt);
};
Define_Module(TSN5GTranslator);
void TSN5GTranslator::initialize()
{
    destPort = par("destPort");
    localPort = par(localPort);
}
void TSN5GTranslator::sendPacket(Packet *pkt)
{
    socket.setOutputGate(gate("out"));
     socket.bind(localPort);
     int tos = par("tos");
        if (tos != -1)
            socket.setTos(tos);
    if (destAddress.isUnspecified())
        destAddress = L3AddressResolver().resolve(par("destAddress"));
    Packet* packet = new Packet();
    packet->insertAtBack(pkt->peekAll());
    socket.sendTo(packet, destAddress, destPort);
    socket.close();
}

void TSN5GTranslator::handleMessage(cMessage *msg)
{
    EV << msg->getArrivalGate()->getName() << endl;
    if (strcmp(msg->getName(),"closed") == 0) {
        EV << "closed bind" << endl;
    }
    else if (strcmp(msg->getArrivalGate()->getName(),"in") == 0){

        Packet *pkt = check_and_cast<Packet *>(msg);
        pkt->eraseAtFront(B(28));
        pkt->trim();
        pkt->removeTagIfPresent<PacketProtocolTag>();
        pkt->removeTagIfPresent<InterfaceInd>();
        pkt->removeTagIfPresent<DispatchProtocolReq>();
        auto eph = pkt->popAtFront<EthernetPhyHeader>();
        auto emh = pkt->popAtFront<EthernetMacHeader>();
        auto iteh = pkt->popAtFront<Ieee8021qTagEpdHeader>();
        auto iph = pkt->popAtFront<Ipv4Header>();
        auto a = iph->getTag<MyTag>();
        const MacAddress& new_mac = a->address;
        const auto& new_emh = makeShared<EthernetMacHeader>();
        new_emh->setChunkLength(emh->getChunkLength());
        new_emh->setSrc(emh->getSrc());
        new_emh->setDest(new_mac);
        new_emh->setTypeOrLength(emh->getTypeOrLength());
        pkt->insertAtFront(iph);
        pkt->insertAtFront(iteh);
        pkt->insertAtFront(new_emh);
        pkt->insertAtFront(eph);
        pkt->addTagIfAbsent<PacketProtocolTag>()->setProtocol(&Protocol::ethernetPhy);
        Signal *signal = new Signal(msg->getFullName(), msg->getKind(), pkt->getBitLength());
        signal->encapsulate(pkt);
        send(signal, "phys$o");
    }
    else {
        Signal *signal = check_and_cast<Signal *>(msg);
        Packet *pkt = check_and_cast<Packet *>(signal->decapsulate());
        sendPacket(pkt);
    }


}


