test_that("events follows an expected structure", {
  expect_true(
    length(metadata) == length(events)
  )

  expected_names <-
    c("nodes", "flows_l", "flows_od", "spatial", "network", "hparams")

  lapply(
    events,
    function(x) names(x) == expected_names
  )
})
