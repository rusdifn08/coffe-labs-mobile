from PIL import Image
import os

img_path = r'C:\Users\user\.gemini\antigravity\brain\40f1eaa8-ab6b-4ab6-972c-dcb4dcb3667b\.user_uploaded\media_1793588144201_375bcb97.png'
im = Image.open(img_path).convert('RGB')
W, H = im.size
print(f"Image dimensions: {W} x {H}")

# Check y positions
# Look at the screenshot:
# Row 1: y from 33 to 142
# Row 2: y from 240 to 349
# Row 3: y from 447 to 556
# Row 4: y from 654 to 763
# Row 5 (bottom partial): y from 861... wait, height is 811, let's see what is at the bottom:
# Let's see what is around y=760 to 811

crops = {
    "mknd_bali_kintamani.jpg": (13, 33, 125, 142),
    "mknd_kopi_excelsa.jpg": (135, 33, 246, 142),
    "mknd_aceh_gayo.jpg": (13, 240, 125, 349),
    "fugol_sample_c.jpg": (135, 240, 246, 349),
    "mknd_toraja_sapan.jpg": (13, 447, 125, 556),
    "fugol_sample_a.jpg": (135, 447, 246, 556),
    "fugol_sample_b.jpg": (13, 654, 125, 763),
    "mahugi_ijen_carbonic.jpg": (135, 654, 246, 763),
    "kamojang_classico.jpg": (13, 861, 125, 811), 
    "mahugi_rancabali.jpg": (135, 861, 246, 811),
}

# Check bottom of image:
print("Crop row 5 test: y from 860 is > 811. What is at y > 763?")
# Row 5 in this screenshot:
# y from 861 is not possible if H=811. Let's see why:
# Wait! y from 763 to 811:
print("Last 50 pixels (760 to 811):")
# Let's crop y from 765 to 811:
im.crop((0, 760, W, H)).save(r'coffe-labs-mobile\assets\images\beans\bottom_slice.jpg')

for name, box in crops.items():
    if box[1] < H:
        actual_bottom = min(box[3], H)
        if actual_bottom > box[1] + 20:
            c = im.crop((box[0], box[1], box[2], actual_bottom))
            c_up = c.resize((c.width * 3, c.height * 3), Image.Resampling.LANCZOS)
            out_path = os.path.join(r'coffe-labs-mobile\assets\images\beans', name)
            c_up.save(out_path, quality=95)
            print(f"Saved {name}: {c.size} -> {c_up.size}")
