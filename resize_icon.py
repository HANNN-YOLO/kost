"""
Script untuk membuat icon FULL BORDER (SEMUA SISI)
Menghapus whitespace dan memperbesar logo ke SELURUH AREA

Cara pakai:
1. Install Pillow: pip install Pillow
2. Jalankan: python resize_icon.py
"""

from PIL import Image
import os

def create_full_border_icon(input_path, output_path, target_size=1024):
    """
    Crop whitespace dan STRETCH logo agar FULL ke semua border
    
    Args:
        input_path: Path gambar asli
        output_path: Path gambar output
        target_size: Ukuran output (1024x1024 recommended)
    """
    print(f"📂 Membuka: {input_path}")
    
    # Buka gambar
    img = Image.open(input_path)
    
    # Convert ke RGBA jika belum
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    print(f"📐 Ukuran asli: {img.size}")
    
    # Cari bounding box dari konten non-transparan/non-putih
    pixels = img.load()
    min_x, min_y = img.size
    max_x, max_y = 0, 0
    
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pixels[x, y]
            # Jika pixel bukan putih murni dan tidak transparan
            if a > 10 and not (r > 245 and g > 245 and b > 245):
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    
    if max_x > min_x and max_y > min_y:
        bbox = (min_x, min_y, max_x + 1, max_y + 1)
        print(f"✂️ Cropping area: {bbox}")
        
        # Crop gambar (hapus semua whitespace)
        cropped = img.crop(bbox)
    else:
        print("⚠️ Tidak bisa detect konten, pakai gambar asli")
        cropped = img
    
    crop_w, crop_h = cropped.size
    print(f"📐 Ukuran setelah crop: {crop_w} x {crop_h}")
    
    # ============================================
    # METODE: SCALE PENUH KE SELURUH AREA
    # Logo akan di-stretch agar memenuhi 95% area
    # ============================================
    
    # Padding kecil di setiap sisi (2.5% = 5% total)
    padding_percent = 0.025
    padding = int(target_size * padding_percent)
    usable_size = target_size - (padding * 2)
    
    print(f"📐 Area usable: {usable_size} x {usable_size}")
    
    # RESIZE logo ke ukuran penuh (akan sedikit stretch jika tidak square)
    # Ini membuat logo FULL ke semua border
    resized = cropped.resize((usable_size, usable_size), Image.Resampling.LANCZOS)
    
    print(f"📐 Ukuran logo setelah resize: {resized.size}")
    
    # Buat canvas putih
    canvas = Image.new('RGBA', (target_size, target_size), (255, 255, 255, 255))
    
    # Paste logo di tengah dengan padding minimal
    canvas.paste(resized, (padding, padding), resized)
    
    # Simpan sebagai PNG
    canvas.save(output_path, 'PNG')
    print(f"✅ Tersimpan: {output_path}")
    print(f"📐 Ukuran final: {target_size}x{target_size}")
    print(f"📐 Logo mengisi: {100 - (padding_percent * 200)}% area (FULL BORDER)")
    
    return output_path

if __name__ == "__main__":
    # Path file
    base_path = os.path.dirname(os.path.abspath(__file__))
    assets_path = os.path.join(base_path, "lib", "assets")
    
    # Input: gambar asli
    input_file = os.path.join(assets_path, "6f07a055-196a-40b0-9344-833a80d267fb.png")
    
    # Output: gambar FULL BORDER
    output_file = os.path.join(assets_path, "icon_full_border.png")
    
    print("=" * 50)
    print("🎨 ICON FULL BORDER GENERATOR (ALL SIDES)")
    print("=" * 50)
    
    if not os.path.exists(input_file):
        print(f"❌ File tidak ditemukan: {input_file}")
        print("Coba file alternatif...")
        input_file = os.path.join(assets_path, "coba_scale.png")
    
    if os.path.exists(input_file):
        create_full_border_icon(
            input_path=input_file,
            output_path=output_file,
            target_size=1024
        )
        print("\n" + "=" * 50)
        print("🎉 SELESAI! Logo sekarang FULL ke semua border!")
        print("=" * 50)
    else:
        print(f"❌ Tidak ada file icon di {assets_path}")
