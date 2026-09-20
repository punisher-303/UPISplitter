# 💸 UPISplitter

<div align="center">
  <h3><strong>Smart Transaction Slicing & Zero-Fee UPI Routing Engine</strong></h3>
  <p>A cutting-edge financial utility crafted with Flutter and the stunning NeoPOP UI framework.</p>

  <p>
    <a href="https://punisher-303.github.io/UPISplitter/"><img src="https://img.shields.io/badge/Web-Live_Demo-00BAF2?style=for-the-badge&logoColor=black" alt="Live Demo" /></a>
    <a href="https://github.com/punisher-303/UPISplitter"><img src="https://img.shields.io/badge/Platform-Flutter_3.x-042E6F?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
    <a href="https://github.com/punisher-303/UPISplitter"><img src="https://img.shields.io/badge/UI_UX-CRED_NeoPOP-00BAF2?style=for-the-badge&logo=flutter&logoColor=black" alt="CRED NeoPOP" /></a>
    <a href="https://github.com/punisher-303/UPISplitter"><img src="https://img.shields.io/badge/Fees-0%25_MDR-00FF66?style=for-the-badge" alt="0% MDR" /></a>
  </p>
</div>

---

> [!NOTE]
> ### 🔬 **Research & Educational Notice**
> **UPISplitter is engineered solely as a technical proof-of-concept for academic and algorithmic research.** 
> This repository demonstrates the mechanics of UPI deep-linking, client-side transaction orchestration, and the mathematical implications of NPCI's merchant fee thresholds. 

---

## 🧠 Core Philosophy: The Zero-Fee Routing Protocol

Based on the latest financial guidelines, standard UPI payments made to merchants that exceed the **₹2,000** mark are subjected to a Merchant Discount Rate (MDR) of up to 0.4%, compounded by an additional 18% GST on that fee. Conversely, any transaction valued at ₹2,000 or below is entirely exempt from these surcharges.

**UPISplitter** tackles this overhead by acting as an algorithmic mediator. Instead of processing a single heavy transaction (e.g., ₹6,800), the engine dynamically segments the total amount into optimal, compliant micro-installments:

$$\text{Gross Payable} = \sum_{x=1}^{n} \text{Segment}_x \quad \text{where} \quad \forall x, \; \text{Segment}_x \le ₹1,999.00$$

By keeping every individual payment segment under the radar, the aggregate gateway fee drops to **absolute zero**.

---

## 🌟 Key Capabilities

- 🔪 **Smart Bill Slicing**: A robust mathematical engine that instantly calculates and divides large invoices into fee-exempt chunks.
- 🧊 **Immersive Neo-Brutalist UI**: Designed entirely around the CRED NeoPOP ecosystem, featuring high-contrast 3D components and dynamic depth.
- 📢 **Digital Soundbox Integration**: Comes with a built-in virtual speaker that audibly mimics the real-time payment confirmations found in modern retail stores.
- 🤝 **Seamless Group Splitting**: Effortlessly divide dining checks among friends and generate direct zero-fee payment links for social sharing.
- 📷 **Native QR Decoding**: A lightning-fast camera integration that parses complex merchant UPI intents on the fly.
- 📈 **Savings Analytics**: Includes a dedicated calculator to visualize how much capital is lost annually to standard MDR vs. saved using our routing method.

---

## 🏗️ Under the Hood

- **Core Engine**: [Flutter](https://flutter.dev) (Dart Ecosystem)
- **Visual Language**: [`neopop`](https://pub.dev/packages/neopop) (Official CRED Design)
- **Code Architecture**: Modular MVC & Service-Oriented Design
- **Camera Operations**: [`mobile_scanner`](https://pub.dev/packages/mobile_scanner)
- **Barcode Rendering**: [`qr_flutter`](https://pub.dev/packages/qr_flutter)
- **System Intents**: [`url_launcher`](https://pub.dev/packages/url_launcher), [`share_plus`](https://pub.dev/packages/share_plus)

---

## ⚙️ Setup Instructions

### What you need
- Flutter SDK (version `>=3.3.0`)
- Your preferred IDE (VS Code, Android Studio, etc.)

### Quick Start

```bash
# 1. Grab the source code
git clone https://github.com/punisher-303/UPISplitter.git

# 2. Enter the workspace
cd UPISplitter

# 3. Fetch packages
flutter pub get

# 4. Launch the application
flutter run
```

---

<div align="center">
  <h3>Let's Connect</h3>
  <a href="https://instagram.com/appuz.404">Instagram (@appuz.404)</a> • 
  <a href="mailto:anandpm224@gmail.com">Email (anandpm224@gmail.com)</a> • 
  <a href="https://github.com/punisher-303">GitHub (punisher-303)</a>
  <br><br>
  <sub>Built with ⚡ by Anand</sub>
</div>