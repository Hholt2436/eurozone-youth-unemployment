library(ggdag)
library(ggplot2)

ink <- "#1A1A2E"; accent <- "#C0392B"; accent2 <- "#2471A3"; muted <- "#6B6860"

#Acyclic Skeleton
dag <- dagify(
  D ~ U,              
  X ~ U + D,          
  Y ~ U + D + X,      
  exposure = "D",
  outcome  = "Y",
  latent   = "U",     
  labels = c(
    U = "Unobservables",
    D = "EPL strictness",
    X = "GDP growth",
    Y = "Youth unemployment"
  ),
  coords = list(
    x = c(U = 0, D = 1, X = 1, Y = 2),
    y = c(U = 1, D = 2, X = 0, Y = 1)
  )
)

key <- data.frame(x = NA_real_, y = NA_real_,
                  edge = factor(c("structural", "reverse / feedback"),
                                levels = c("structural", "reverse / feedback")))

p <- dag |>
  tidy_dagitty() |>
  ggplot(aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_dag_edges(edge_colour = muted) +
  geom_dag_point(aes(colour = name), size = 18, show.legend = FALSE) +
  geom_dag_text(aes(label = name), colour = "white", size = 5) +
  scale_colour_manual(values = c(U = muted, D = accent, X = accent2, Y = ink)) +
  theme_dag()

p_2 <- p +
  geom_segment(data = key, aes(x = x, y = y, xend = x, yend = y, linetype = edge)) +
  scale_linetype_manual(NULL,
                        values = c("structural" = "solid", "reverse / feedback" = "dashed")) +
  theme(legend.position = "bottom") +
  annotate("curve", x = 1.95, y = 1.16, xend = 1.1, yend = 2,  
           curvature = 0.22, linetype = "dashed", colour = muted,
           arrow = arrow(length = unit(0.02, "npc"))) +
  annotate("curve", x = 1.95, y = 0.84, xend = 1.1, yend = 0, 
           curvature = -0.22, linetype = "dashed", colour = muted,
           arrow = arrow(length = unit(0.02, "npc")))
  

ggsave("outputs/dag.png", p_2, width = 7, height = 5, dpi = 300, bg = "#F7F5F0")
ggsave("outputs/dag.pdf", p_2, width = 7, height = 5, bg = "#F7F5F0")

