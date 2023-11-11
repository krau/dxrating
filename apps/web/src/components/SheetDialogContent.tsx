import {
  Button,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
} from "@mui/material";
import clsx from "clsx";
import { FC, useMemo } from "react";
import IconMdiYouTube from "~icons/mdi/youtube";
import { FlattenedSheet } from "../songs";
import { calculateRating } from "../utils/rating";
import { DXRank } from "./DXRank";
import { SheetImage, SheetTitle } from "./SheetListItem";

const PRESET_ACHIEVEMENT_RATES = [
  100.5, 100, 99.5, 99, 98, 97, 94, 90, 80, 75, 70, 60, 50, 0,
];

export interface SheetDialogContentProps {
  sheet: FlattenedSheet;
  currentAchievementRate?: number;
}

export const SheetDialogContent: FC<SheetDialogContentProps> = ({
  sheet,
  currentAchievementRate,
}) => {
  const ratings = useMemo(() => {
    const rates = [...PRESET_ACHIEVEMENT_RATES];
    if (currentAchievementRate) {
      rates.push(currentAchievementRate);
    }
    rates.sort((a, b) => b - a);
    return rates.map((rate) => ({
      achievementRate: rate,
      rating: calculateRating(sheet.internalLevelValue, rate),
    }));
  }, [sheet, currentAchievementRate]);

  return (
    <div className="flex flex-col gap-2 relative">
      <div className="flex items-center">
        <SheetImage name={sheet.imageName} />

        <div className="flex-1" />

        <div className="text-4xl text-zinc-900/60 leading-none">
          {sheet.internalLevelValue.toFixed(1)}
        </div>
      </div>

      <SheetTitle
        title={sheet.title}
        altNames={sheet.searchAcronyms}
        difficulty={sheet.difficulty}
        type={sheet.type}
        version={sheet.version}
        className="text-lg font-bold"
      />

      <Button
        startIcon={<IconMdiYouTube />}
        variant="outlined"
        href={`https://www.youtube.com/results?search_query=${sheet.title}+${sheet.difficulty}`}
        target="_blank"
        className="inline-flex !text-[#ff0000] !b-[#ff0000] !font-bold self-start"
      >
        Search on YouTube
      </Button>

      <Table className="tabular-nums !font-mono" size="small">
        <TableHead>
          <TableRow>
            <TableCell>Achv</TableCell>
            <TableCell>Rating</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {ratings.map((rating, i) => {
            const nextRating = i === ratings.length - 1 ? null : ratings[i + 1];

            return (
              <TableRow
                key={rating.achievementRate}
                sx={{ "&:last-child td, &:last-child th": { border: 0 } }}
                className={clsx(
                  rating.achievementRate === currentAchievementRate &&
                    "bg-amber",
                )}
              >
                <TableCell component="th" scope="row">
                  <div className={clsx("flex items-center font-sans")}>
                    <DXRank rank={rating.rating.rank} className="h-8" />
                    <span>
                      <SheetAchievementRate value={rating.achievementRate} />
                    </span>
                  </div>
                </TableCell>
                <TableCell>
                  <div className="relative font-sans">
                    <span className="font-bold">
                      {rating.rating.ratingAwardValue}
                    </span>

                    {nextRating && (
                      <div className="absolute -bottom-5 -left-1 px-1 text-xs text-gray-500 bg-zinc-100 shadow-[0_0_0_1px_var(--un-shadow-color)] shadow-zinc-300/80 rounded-xs">
                        ↑ +
                        {rating.rating.ratingAwardValue -
                          nextRating.rating.ratingAwardValue}
                      </div>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </div>
  );
};

const SheetAchievementRate: FC<{ value: number }> = ({ value }) => {
  const integer = Math.floor(value);
  const decimal = value % 1;

  return (
    <div className="inline-flex items-center">
      <span className="font-bold">{integer}</span>
      <span>.</span>
      <span className={clsx(decimal === 0 && "text-zinc-4")}>
        {decimal.toFixed(4).slice(2)}
      </span>
      <span>%</span>
    </div>
  );
};
