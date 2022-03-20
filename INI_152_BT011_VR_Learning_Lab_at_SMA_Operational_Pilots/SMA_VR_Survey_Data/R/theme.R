uhg1 = rgb(red = 45, green = 95, blue = 167, maxColorValue = 255)      # #2d5fa7    UHG blue
uhg2 = rgb(red = 247, green = 152, blue = 55, maxColorValue = 255)     # #f79837    UHG orange
uhg3 = rgb(red = 114, green = 192, blue = 96, maxColorValue = 255)     # #72c060    UHG green
uhg4 = rgb(red = 234, green = 75, blue = 77, maxColorValue = 255)      # #ea4b4d    UHG red
uhg5 = rgb(red = 2, green = 142, blue = 167, maxColorValue = 255)      # #028ea7    UHG teal
uhg6 = rgb(red = 103, green = 93, blue = 168, maxColorValue = 255)     # #675da8    UHG purple
uhgGrey = rgb(red = 166, green = 166, blue = 166, maxColorValue = 255) # #A6A6A6    UHG gray 

text_size_ = 13
theme_joy_s = theme(axis.line = element_line(color = uhgGrey, size = 2),
                    panel.grid.major.y = element_line(color = uhgGrey, size = 0.2, linetype = 2),
                    panel.background = element_rect(fill = 'white'),
                    axis.ticks = element_line(size = 1.5),        # Add axis ticks
                    axis.ticks.length = unit(0.15, 'cm'),
                    axis.text = element_text(size = text_size_, color = "#222222"),
                    axis.text.x = element_text(size = text_size_, vjust = 0.9),
                    axis.text.y = element_text(size = text_size_),
                    axis.title = element_text(size = text_size_, face = 'bold'),
                    legend.position = 'right',
                    legend.title = element_text(size = text_size_),
                    legend.text = element_text(size = text_size_ - 0),
                    legend.margin = margin(t = 0.2, r = 0.2, l = 0.2, b = 0.2, unit = 'cm'),
                    legend.background = ggplot2::element_blank(), # remove surrounding gray color
                    legend.key = ggplot2::element_blank(),     
                    panel.spacing = unit(5, 'pt'),
                    strip.text = element_text(size = text_size_ + 1),
                    plot.title = element_text(size = text_size_ + 4, face = 'bold', hjust = 0.5),
                    plot.subtitle = element_text(size = text_size_ + 2, hjust = 0.5))