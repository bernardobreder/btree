import java.io.IOException;

public interface BTreeInterface {

	public BTreeNode readTreeNode(int id) throws IOException;
	
}
