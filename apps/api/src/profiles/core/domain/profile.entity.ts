export const AVATAR_STYLES = ["BLUE", "YELLOW", "RED", "KIDS"] as const;

export type AvatarStyle = (typeof AVATAR_STYLES)[number];

export type Profile = {
  id: string;
  name: string;
  avatar: AvatarStyle;
  isKids: boolean;
  position: number;
};
