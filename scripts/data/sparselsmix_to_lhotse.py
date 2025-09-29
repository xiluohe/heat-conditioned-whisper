import argparse
import os

from lhotse import CutSet, MonoCut, fix_manifests, load_manifest, SupervisionSegment
from lhotse.audio import Recording
from tqdm import tqdm

import json

def load_metadata(mixture_manifest_path):
    with open(mixture_manifest_path) as json_file:
        data = json.load(json_file)

    mixture_metadata = {
        ex["mixture_name"]: {k: v for k, v in ex.items() if k != "mixture_name"} for ex in data
    }
    return mixture_metadata

def main(mixture_metadata, mixture_wavs_dir, output_manifest):
    mixed_cuts = []
    
    for wav in tqdm(os.listdir(mixture_wavs_dir)):
        if '.wav' not in wav:
            continue

        mixture_name = wav.split('.')[0]

        rec = Recording.from_file(f'{mixture_wavs_dir}/{wav}', mixture_name)
        sups = []

        metadata = mixture_metadata[mixture_name]

        source_ids = [k for k in metadata.keys() if k != 'noise']

        for src_id in source_ids:
            src = metadata[src_id]

            for seg in src:

                sup = SupervisionSegment(
                    id=seg.get("utt_id"),
                    recording_id=mixture_name,
                    start=float(seg.get("start", 0.0)),
                    duration=round(float(seg.get("stop", 0.0)) - float(seg.get("start", 0.0)), 3),
                    channel=0,
                    text=" ".join(seg.get("words")),
                    language="English",
                    speaker=seg.get("spk_id")
                )
                
                sups.append(sup)

        for sup in sups:
            sup.recording_id = rec.id

        mixed_cuts.append(MonoCut(
            id=mixture_name,
            start=0,
            duration=rec.duration,
            channel=0,
            recording=rec,
            supervisions=sups
        ))

    CutSet.from_cuts(mixed_cuts).to_file(output_manifest)
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--mixture_metadata', type=str, required=True)
    parser.add_argument('--mixture_wavs_dir', type=str, required=True)
    parser.add_argument('--output_manifest', type=str, required=True)

    args = parser.parse_args()
    
    main(load_metadata(args.mixture_metadata), args.mixture_wavs_dir, args.output_manifest)
