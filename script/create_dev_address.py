from bip_utils import Bip39MnemonicGenerator, Bip39SeedGenerator, Bip44, Bip44Coins, Bip44Changes

# Generate a valid mnemonic phrase (12 words)
mnemonic = Bip39MnemonicGenerator().FromWordsNumber(12)

# Print the mnemonic
print(f"Mnemonic: {mnemonic}")

# Generate seed from mnemonic
seed_bytes = Bip39SeedGenerator(mnemonic).Generate()

# Generate the BIP44 wallet
bip44_mst_ctx = Bip44.FromSeed(seed_bytes, Bip44Coins.ETHEREUM)
bip44_acc_ctx = bip44_mst_ctx.Purpose().Coin().Account(0).Change(Bip44Changes.CHAIN_EXT)

# Get the address index 0 (you can change it as per your need)
bip44_addr_ctx = bip44_acc_ctx.AddressIndex(0)

# Get the private key in hex format
private_key = bip44_addr_ctx.PrivateKey().Raw().ToHex()
print(f"Private Key: {private_key}")


from mnemonic import Mnemonic
from bip_utils import Bip39SeedGenerator, Bip44, Bip44Coins, Bip44Changes

# Generate a random mnemonic
mnemo = Mnemonic("english")
mnemonic = mnemo.generate(strength=256)
print(f"Mnemonic: {mnemonic}")