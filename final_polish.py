import os
import re
import hashlib
import glob

# 1. Update CTS
cts = 'zero-cloud-core-conformance-test-specification.md'
with open(cts, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('certified to withstand invasive physical attacks following ISO/IEC 17065-accredited procedures', 'evaluated to pass the defined invasive physical assessment under the declared attack capability and evaluation scope following ISO/IEC 17025-accredited testing procedures (with certification/conformity assessment performed under an applicable ISO/IEC 17065 scheme where required)')
text = text.replace('certified to mitigate fault injection attempts following ISO/IEC 17065-accredited procedures', 'evaluated to pass the defined fault injection assessment under the declared attack capability and evaluation scope following ISO/IEC 17025-accredited testing procedures (with certification/conformity assessment performed under an applicable ISO/IEC 17065 scheme where required)')

text = text.replace('evidence relevant to selected cybersecurity requirements under the EU Cyber Resilience Act (CRA)', 'evidence relevant to selected cybersecurity considerations; it does not constitute formal EU Cyber Resilience Act (CRA) conformity assessment or legal compliance')

text = text.replace('N = 1,000,000 independent, identically distributed (i.i.d.) Edge AI inference executions.', 'N = 1,000,000 independent, identically distributed (i.i.d.) Edge AI inference executions. The i.i.d. requirement SHALL be operationally met via randomized acquisition order, environmental temperature control, and stable power-supply calibration.')

text = text.replace('OTP/eFuse or Hardware Security Modules', 'hardware-protected key storage meeting the defined security property (e.g., OTP/eFuse, HSM, or Secure Enclave)')

text = text.replace('override—even', 'override-even')
text = text.replace('overrideâ€”even', 'override-even')
text = text.replace('* **Forbidden Bypass:**', "* **Execution:** This test MUST explicitly invoke the Annex B Mutual Information (MI) protocol to empirically prove the MI bound.\n* **Forbidden Bypass:**")

with open(cts, 'w', encoding='utf-8', newline='\n') as f:
    f.write(text)


# 2. Update Evidence Matrix
ev = 'zero-cloud-core-conformance-evidence-matrix.md'
with open(ev, 'r', encoding='utf-8') as f:
    text = f.read()
text = text.replace('ISO/IEC 17065 Certification', 'ISO/IEC 17065 Scheme / 17025 Testing')
with open(ev, 'w', encoding='utf-8', newline='\n') as f:
    f.write(text)


# 3. Update Brand Policy
brand = 'zero-cloud-core-brand-and-trademark-policy.md'
with open(brand, 'r', encoding='utf-8') as f:
    text = f.read()
roleText = "\n> **Note on Certification Role:** FreeCuli acts solely as the Standard Owner and Certification Scheme Owner. FreeCuli is NOT an ISO/IEC 17065 certification body itself. Final certification requires independent test reports from ISO/IEC 17025 accredited laboratories.\n"
text = text.replace('### 4. FreeCuli Certified', roleText + '\n### 4. FreeCuli Certified')
with open(brand, 'w', encoding='utf-8', newline='\n') as f:
    f.write(text)


# 4. Update Dual Licensing
dual = 'zero-cloud-dual-licensing.md'
with open(dual, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('License Contamination Shield', 'Commercial Intellectual Property Exemption')
text = text.replace('acts as a waiver, removing the copyleft obligations', 'grants permissions expressly defined by FreeCuli for the FreeCuli-controlled materials, exempting them from the standard copyleft obligations')
text = text.replace('is **immediately subject to strict worldwide revocation under applicable license terms**', 'is **subject to worldwide revocation under applicable license terms** (Subject to valid legal claims, applicable law, and specifically applying to FreeCuli-controlled IP)')

with open(dual, 'w', encoding='utf-8', newline='\n') as f:
    f.write(text)


# 5. Manifest Hashing
exclude = ['DUAL-LICENSING.md', 'Zero-Cloud-Smart-Home-Edge-AI-Architecture.md', 'Zero-Cloud-Defensive-Publication.md', 'FC-ZC-Conformance-Test-Specification.md', 'ZERO-CLOUD-RELEASE-MANIFEST.md', 'ZC-CORE-METHODOLOGY-INVARIANTS.md']

hashes = []
for file in sorted(glob.glob('*.md')):
    if file not in exclude:
        with open(file, 'rb') as f:
            h = hashlib.sha256(f.read()).hexdigest().upper()
            hashes.append(f'{h}  {file}')

hashText = '\n'.join(hashes)

manifest = 'ZERO-CLOUD-RELEASE-MANIFEST.md'
with open(manifest, 'r', encoding='utf-8') as f:
    m_text = f.read()

start = m_text.find('```text')
end = m_text.find('```', start + 7)
if start >= 0 and end >= 0:
    new_m = m_text[:start+7] + '\n' + hashText + '\n' + m_text[end:]
    with open(manifest, 'w', encoding='utf-8', newline='\n') as f:
        f.write(new_m)

print('Done')
