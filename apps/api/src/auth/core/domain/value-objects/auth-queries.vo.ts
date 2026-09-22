import { z } from "zod";

// Le minimum de 8 caractères n'est imposé qu'à l'inscription : l'exiger aussi à
// la connexion rendrait inaccessibles les comptes créés sous une règle plus souple.
export const signUpQuerySchema = z.object({
  email: z.email(),
  password: z.string().min(8),
  name: z.string().min(1),
});

export const signInQuerySchema = z.object({
  email: z.email(),
  password: z.string().min(1),
});

export type SignUpQuery = z.infer<typeof signUpQuerySchema>;
export type SignInQuery = z.infer<typeof signInQuerySchema>;
