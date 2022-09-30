# 直接用R写应用程序 | reactive表达式

在之前的推文中，我们介绍了如何在R语言中，用Shiny包编写应用程序App。在这篇推文中，我们将要介绍Shiny包中一类独特且重要的表达式：reactive expressions。

在设计App时，我们希望App能够有较快的响应速度。但是，如果App的server函数中包含很多耗时较长的运算，那么应该怎么办呢？此时，就需要用到Reactive表达式。它能够控制程序中哪些部分需要更新运算，而哪些部分不需要更新，从而节省运算时间。

## 案例：stockVis

此处，我们将通过一个案例来讲解reactive表达式。下图是stockVis的App界面，这个App能够帮助用户描绘相应股票的价格变动。感兴趣的读者可以根据[此处](https://shiny.rstudio.com/tutorial/written-tutorial/lesson6/)的提示下载该App。

![](img/2图1.png)

根据上图可以看出，用户需要首先选择股票（Symbol），然后选择观察时期(Data range)，再选择绘制原股票价格还是对数化后的股票价格，最后再选择是否股价中的通胀进行矫正。

在对这些选项进行了选择之后，stockVis首先用`getSymbols`函数从诸如[Yahoo finance](https://consent.yahoo.com/v2/collectConsent?sessionId=3_cc-session_b4231433-d1e7-4b31-8341-a7d413ea7922)和[Federal Reserve Bank of St. Louis](https://fred.stlouisfed.org)这样的网站中下载金融数据到R，然后再用`chartSeries`将股价描绘出来。

server函数中，用来生成图形的程序如下。在分析了该程序之后，我们会发现一个问题。比如，当我们重新选中“Plot y axis on the log scale”，那么`input$log`的值就会变化，那么就会导致整个`renderPlot`重新进行运算。

```r
output$plot <- renderPlot({
  data <- getSymbols(input$symb, src = "yahoo",
                     from = input$dates[1],
                     to = input$dates[2],
                     auto.assign = FALSE)

  chartSeries(data, theme = chartTheme("white"),
              type = "line", log.scale = input$log, TA = NULL)
})
```

而`renderPlot`每次重新运算时，首先会重新用`getSymbols`抓去数据，然后用`chartSeries`重新画图。然而，用`getSymbols`从Yahoo等网站抓取数据所花费的时间并不是可以忽略不计的。另外，如果抓取的过于频繁，我们的IP地址会被屏蔽，这是网站将我们错判为机器人，也是网站应对爬虫的常用做法。最关键的是，当我们只是重新选择“Plot y axis on the log scale”，我们并不希望重新抓取数据，而是希望在原有数据的基础上对数化即可。


## Reactive表达式

在遇到上述问题时，我们就需要用到reactive表达式。reactive表达式以ui函数里各种input变量作为输入。如下，reactive表达式的输入则是`input$symb`和`input$dates`。当`input$symb`和`input$dates`的值变化时，此处reactive表达式的输出结果才会发生变化，而不受`input$log`的影响。

```r
dataInput <- reactive({
  getSymbols(input$symb, src = "yahoo",
    from = input$dates[1],
    to = input$dates[2],
    auto.assign = FALSE)
})
```

所以，我们现在用上面的reactive表达式更新原先的程序，得到如下程序。`dataInput()`命令则是运行如上的reactive表达式。此时，如果我们只重新选择"Plot y axis on the log scale"，那么reactive表达式里的数据抓取过程并不会更新，而只有`renderPlot`里的`log.scale`参数会更新，这将节省程序运行时间，而且减少数据抓取次数，防止IP地址被封。

```r
output$plot <- renderPlot({    
  chartSeries(dataInput(), theme = chartTheme("white"),
    type = "line", log.scale = input$log, TA = NULL)
})
```


reactive表达式不止`reactive()`，还包括`observe()`, `observeEvent()`和`eventReactive()`等等，详见[此处](https://shiny.rstudio.com/reference/shiny/1.6.0/)。另外，reactive表达式只能包装在特定的、允许reactive表达式的函数中，如此处的`renderPlot`，而不能被包装在`plot`函数中。`render*`类函数都允许reactive表达式。

## 总结

Reactive表达式的功能可被简单地总结为以下步骤：

- 当你第一次运行程序时，reactive表达式会缓存运行结果。
- 当你下一次运行程序时，reactive表达式会自动检测输入值是否是最新的。在上例中，也就是说输入的`input$symb`和`input$dates`是否有变化。
- 如果有变化，则reactive会根据新输入值更新结果。
- 如果没变化，则reactive会直接使用缓存中的值。

## 参考文献

[https://shiny.rstudio.com/tutorial/written-tutorial/lesson6/](https://shiny.rstudio.com/tutorial/written-tutorial/lesson6/)

