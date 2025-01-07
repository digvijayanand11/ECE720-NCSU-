retrain: mymodel.pt
	date +%s > retrain.begin
	python3 retrain.py 500

train:
	date +%s > train.begin
	python3 train.py 500

clean:
	-rm myadapter*.pt retrain-loss*.png
	-rm retrain retrain.begin adapter-error-summary.png

cleanbase:
	-rm mymodel*.pt train-loss*.png
	-rm myadapter*.pt retrain-loss*.png
	-rm train train.begin basemodel-error-summary.png
	-rm retrain retrain.begin adapter-error-summary.png
	-rm mymodel.pt


